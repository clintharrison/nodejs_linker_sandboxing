"""Bundle assets with Webpack"""

load("@build_bazel_rules_nodejs//:providers.bzl", "NodeRuntimeDepsInfo", "NpmPackageInfo", "node_modules_aspect", "run_node")
load(
    "@build_bazel_rules_nodejs//internal/linker:link_node_modules.bzl",
    "module_mappings_aspect",
    "register_node_modules_linker",
)

def _to_runfiles_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _get_deps_inputs(ctx):
    deps_depsets = []
    for dep in ctx.attr.deps:
        if hasattr(dep, "files"):
            deps_depsets.append(dep.files)
        if NpmPackageInfo in dep:
            deps_depsets.append(dep[NpmPackageInfo].sources)

    return depset(transitive = deps_depsets).to_list()

def _webpack_bundle_impl(ctx):
    gen_config_file = ctx.actions.declare_file("%s.gen.config.js" % ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._config_template,
        output = gen_config_file,
        substitutions = {
            "TEMPLATED_BASE_CONFIG_PATH": ctx.file.config.short_path,
            "TEMPLATED_ENTRY_POINT": ctx.file.entry_point.path,
            "TEMPLATED_OUT_PATH": ctx.outputs.out.path,
        },
    )
    deps_inputs = _get_deps_inputs(ctx)
    inputs = ctx.files.srcs + deps_inputs + [gen_config_file, ctx.file.config]

    run_node(
        ctx,
        inputs = inputs,
        executable = "_webpack_wrapper",
        arguments = ["--config-path=%s" % gen_config_file.path],
        outputs = [ctx.outputs.out],
        mnemonic = "WebpackBundle",
        progress_message = "Bundling JavaScript %s [webpack]" % ctx.outputs.out.short_path,
    )

    return [DefaultInfo(
        files = depset([ctx.outputs.out]),
    )]

webpack_bundle = rule(
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(
            aspects = [module_mappings_aspect, node_modules_aspect],
        ),
        "config": attr.label(allow_single_file = True),
        "entry_point": attr.label(allow_single_file = True),
        "out": attr.output(
            mandatory = False,
            doc = "Output name for a single Webpack bundle",
        ),
        "_webpack_wrapper": attr.label(
            executable = True,
            default = "//webpack_bundle:webpack",
            cfg = "exec",
        ),
        "_config_template": attr.label(
            default = Label("//webpack_bundle:webpack.config.tpl.js"),
            allow_single_file = True,
        ),
    },
    implementation = _webpack_bundle_impl,
)
