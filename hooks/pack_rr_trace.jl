# Install `BugReporting` into a temporary environment
using Pkg
Pkg.activate(; temp=true)
Pkg.add("BugReporting")
using BugReporting

# Compress the latest trace recorded in our overall trace directory
trace_dir = BugReporting.find_latest_trace(ENV["_RR_TRACE_DIR"])
mktempdir() do dir
    pipeline = ENV["BUILDKITE_PIPELINE_NAME"]
    commit = ENV["BUILDKITE_COMMIT"]
    step_id = ENV["BUILDKITE_STEP_ID"]
    tarzst_path = joinpath(dir, "$(pipeline)-$(commit)-$(step_id).tar.zst")
    BugReporting.compress_trace(trace_dir, tarzst_path)
    run(`buildkite-agent artifact upload $(tarzst_path)`)
end