#!/usr/bin/env python3
import yaml
import os
import sys
import subprocess

try:
    # Import Manifest.yml
    current_dir = os.path.dirname(os.path.realpath(__file__))

    with open(os.path.join(current_dir, "../../Manifest.yml"), "r") as stream:
        manifest = yaml.safe_load(stream)

    ios_repo = manifest["global"]["ios"]["repo"]
    ios_package = manifest["go_core"]["ios"]["package"]
    description = manifest["go_core"]["ios"]["summary"]
    licenses = [license["short_name"]
                for license in manifest["global"]["licenses"]]
    vcs_url = manifest["global"]["github"]["git_url"]
    website = manifest["global"]["github"]["url"]
    issue_tracker = manifest["global"]["github"]["issues_url"]
    github_repo = manifest["global"]["github"]["repo"]
    github_notes = manifest["go_core"]["ios"]["github_release_notes_file"]
    download_count = manifest["go_core"]["ios"]["public_download_numbers"]
    readme_content = manifest["go_core"]["ios"]["readme_content"]
    readme_syntax = manifest["go_core"]["ios"]["readme_syntax"]
    core_name = manifest["go_core"]["ios"]["name"]
    publish = manifest["go_core"]["ios"]["publish"]
    override = manifest["go_core"]["ios"]["override"]

    # Get version from env (CI) or fail
    if "GOMOBILE_IPFS_VERSION" in os.environ:
        global_version = os.getenv("GOMOBILE_IPFS_VERSION")
    else:
        raise Exception("can't publish a dev version")

    version_description = "{0}-{1}-{2}".format(
        ios_repo,
        ios_package,
        global_version,
    )
    vcs_tag = "v%s" % global_version

    if publish:
        print("Publishing version: %s for package: %s" %
              (global_version, ios_package))

        pod_version_exists = False
        code, output = subprocess.getstatusoutput(
            "pod trunk info %s | sed -e '1,/- Versions:/d' -e "
            "'/- Owners:/,$d' | cut -f2- -d '-' | rev | cut -f2- "
            "-d '(' | rev" % core_name
        )
        if code == 0:
            for line in output.splitlines():
                if line.strip() == global_version:
                    pod_version_exists = True
                    break

        if not pod_version_exists or (pod_version_exists and override):
            podspec_file = "%s.podspec" % core_name
            if pod_version_exists:
                print("Updating version %s on pod trunk: %s" %
                      (global_version, podspec_file))
                os.system("echo y | pod trunk delete %s %s &> /dev/null" %
                          (core_name, global_version))
            else:
                print("Publishing version %s on pod trunk: %s" %
                      (global_version, podspec_file))

            ios_build_dir_ccp = os.path.join(
                os.path.dirname(os.path.dirname(current_dir)),
                "build/ios/cocoapods",
            )
            version_path = "%s/%s" % (ios_package, global_version)
            artifacts_local_dir = os.path.join(ios_build_dir_ccp, version_path)

            if os.system("pod trunk push %s --skip-import-validation" %
                         os.path.join(artifacts_local_dir, podspec_file)):
                raise Exception("pod trunk push failed")

    print("Cocoapod publication succeeded!")

except Exception as err:
    sys.stderr.write("Error: %s\n" % str(err))
    exit(1)
