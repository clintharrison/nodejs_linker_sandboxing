workspace(
    name = "nodejs_linker_sandboxing",
    managed_directories = {
        "@npm_app": ["app/node_modules"],
    },
)

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "3d7296d834208792fa3b2ded8ec04e75068e3de172fae79db217615bd75a6ff7",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/0.39.1/rules_nodejs-0.39.1.tar.gz"],
)

load("@build_bazel_rules_nodejs//:defs.bzl", "yarn_install")

yarn_install(
    name = "npm_app",
    package_json = "//app:package.json",
    yarn_lock = "//app:yarn.lock",
)

load("@npm_app//:install_bazel_dependencies.bzl", "install_bazel_dependencies")

install_bazel_dependencies()
