using Test, TestPackage

@test TestPackage.greet() == "Hello, World!"

# Check that the plugin's options made it to the test process
if get(ENV, "TESTPACKAGE_CHECK_OPTIONS", "false") == "true"
    @test ARGS == ["foo", "bar"]
    @test Base.JLOptions().opt_level == 0
    @test Base.JLOptions().code_coverage == 0
    @test isfile(joinpath(@__DIR__, "..", "commands_ran"))
else
    @test isempty(ARGS)
    @test Base.JLOptions().code_coverage != 0
end
