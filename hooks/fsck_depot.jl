# Install `BugReporting` into a temporary environment
using Pkg
Pkg.activate(; temp=true)
Pkg.add(; url="https://github.com/KristofferC/PkgFsck.jl")
using PkgFsck

# Delete anything that is corrupted, so it gets properly initialized next time
for corrupted_package in fsck_packages(; remove_cov_files=true)
    println(" - $(corrupted_package.local_path)")
    rm(corrupted_package.local_path; recursive=true, force=true)
end
for corrupted_artifact in fsck_artifacts()
    println(" - $(corrupted_artifact.local_path)")
    rm(corrupted_artifact.local_path; recursive=true, force=true)
end
