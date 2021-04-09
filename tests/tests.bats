#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Create fake "julia" command that just prints out its invocation
echo '#!/bin/bash
echo julia "$@"' > /usr/bin/julia
chmod +x /usr/bin/julia

@test "Basic Instantiation" {
    run $PWD/hooks/pre-command

    assert_output --partial " --project=. "
    assert_output --partial "Pkg.instantiate()"
    assert_output --partial "Pkg.build()"
    assert_output --partial "Pkg.status()"

    # None of these should be present, by default
    refute_output --partial "Pkg.UPDATED_REGISTRY_THIS_SESSION"
    refute_output --partial "Pkg.setprotocol!"
    refute_output --partial "Pkg.Registry.add"
    refute_output --partial "bug-report"

    assert_success
}

@test "Basic Testing" {
    run $PWD/hooks/command

    assert_output --partial " --project=. "
    assert_output --partial "Pkg.test("
    assert_output --partial "coverage=true"
    assert_output --partial "julia_args=\`\`"
    assert_output --partial "test_args=\`\`"
    assert_output --partial "Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true"

    # None of these should be present by default
    refute_output --partial "Pkg.setprotocol!"

    assert_success
}

@test "Project setting (Instantiation)" {
    export BUILDKITE_PLUGIN_JULIA_TEST_PROJECT="examples/foo"
    run $PWD/hooks/pre-command

    assert_output --partial " --project=examples/foo "
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_PROJECT
}

@test "Project setting (Testing)" {
    export BUILDKITE_PLUGIN_JULIA_TEST_PROJECT="examples/foo"
    run $PWD/hooks/command

    assert_output --partial " --project=examples/foo "
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_PROJECT
}

@test "Parameter Setting: coverage" {
    export BUILDKITE_PLUGIN_JULIA_TEST_COVERAGE="false"
    run $PWD/hooks/command

    assert_output --partial "coverage=false"
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_COVERAGE
}

@test "Parameter Setting: julia_args" {
    export BUILDKITE_PLUGIN_JULIA_TEST_JULIA_ARGS="-O0"
    run $PWD/hooks/command

    assert_output --partial "julia_args=\`-O0\`"
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_JULIA_ARGS
}

@test "Parameter Setting: test_args" {
    export BUILDKITE_PLUGIN_JULIA_TEST_TEST_ARGS="foo"
    run $PWD/hooks/command

    assert_output --partial "test_args=\`foo\`"
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_TEST_ARGS
}

@test "Parameter Setting: upload_rr_trace" {
    export BUILDKITE_PLUGIN_JULIA_TEST_UPLOAD_RR_TRACE="always"
    run $PWD/hooks/command

    assert_output --partial "bug-report"
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_UPLOAD_RR_TRACE
}

@test "Registry update skipping" {
    export BUILDKITE_PLUGIN_JULIA_TEST_UPDATE_REGISTRY="false"
    run $PWD/hooks/pre-command

    assert_output --partial "Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true"
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_UPDATE_REGISTRY
}

@test "Using SSH to clone packages (Instantiation)" {
    export BUILDKITE_PLUGIN_JULIA_TEST_USE_SSH="true"
    run $PWD/hooks/command

    assert_output --partial "Pkg.setprotocol!("
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_USE_SSH
}

@test "Using SSH to clone packages (Testing)" {
    export BUILDKITE_PLUGIN_JULIA_TEST_USE_SSH="true"
    run $PWD/hooks/pre-command

    assert_output --partial "Pkg.setprotocol!("
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_USE_SSH
}

@test "Extra Registries" {
    export BUILDKITE_PLUGIN_JULIA_TEST_EXTRA_REGISTRIES="https://github.com/JuliaRegistries/Test,https://github.com/JuliaRegistries/Test2"
    run $PWD/hooks/pre-command

    assert_output --partial 'RegistrySpec(name="General")'
    assert_output --partial 'RegistrySpec(url="https://github.com/JuliaRegistries/Test")'
    assert_output --partial 'RegistrySpec(url="https://github.com/JuliaRegistries/Test2")'
    assert_success
    unset BUILDKITE_PLUGIN_JULIA_TEST_EXTRA_REGISTRIES
}
