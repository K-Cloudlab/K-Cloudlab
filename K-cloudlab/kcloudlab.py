import os
import sys
import subprocess
import shutil

def copy_tf_files(src_dir, dest_dir):
    if not os.path.isdir(src_dir):
        print(f"no scenario found: {src_dir}")
        sys.exit(1)

    os.makedirs(dest_dir, exist_ok=True)

    for filename in os.listdir(src_dir):
        if filename.endswith(".tf"):
            shutil.copy2(os.path.join(src_dir, filename), os.path.join(dest_dir, filename))

    for sub_dir in ["scripts", "policies"]:
        src = os.path.join(src_dir, sub_dir)
        dst = os.path.join(dest_dir, sub_dir)
        if os.path.isdir(src):
            shutil.copytree(src, dst, dirs_exist_ok=True)


def check_scenario():
    config = {}
    try:
        with open("./created_scenario/created_scenario.txt", "r") as f:
            for line in f:
                if "=" in line:
                    k, v = line.strip().split("=", 1)
                    config[k.strip()] = v.strip()
    except FileNotFoundError:
        return False
    return config.get("scenario") != "none"

def parse_args():
    cmd = sys.argv[1] if len(sys.argv) > 1 else None
    scenario = None
    profile = None

    if cmd == "start":
        if len(sys.argv) < 3:
            print("usage: start <scenario_name> [--profile profile_name]")
            sys.exit(1)
        scenario = sys.argv[2]
    else:
        if len(sys.argv) < 2:
            print("usage: finish [--profile profile_name]")
            sys.exit(1)

    if "--profile" in sys.argv:
        idx = sys.argv.index("--profile")
        if len(sys.argv) <= idx + 1:
            print("missing profile name after --profile")
            sys.exit(1)
        profile = sys.argv[idx + 1]

    return cmd, scenario, profile

def main():
    cmd, scenario_name, profile = parse_args()

    if cmd not in ["start", "finish"]:
        print("unknown command")
        sys.exit(1)

    base_dir = os.path.dirname(os.path.abspath(__file__))
    scenario_dir = os.path.join(base_dir, "scenarios", scenario_name, "terraform") if scenario_name else None
    target_dir = os.path.join(base_dir, "created_scenario")

    if profile:
        os.environ["AWS_PROFILE"] = profile
        print(f"Using AWS profile: {profile}")

    chdir_arg = f"-chdir={target_dir}"
    current_scenario = check_scenario()

    if cmd == "start":
        if current_scenario:
            print("already exists a created scenario")
            sys.exit(1)

        copy_tf_files(scenario_dir, target_dir)

        subprocess.run(["terraform", chdir_arg, "init"], check=True)
        subprocess.run(["terraform", chdir_arg, "apply", "-auto-approve"], check=True)

        with open("./created_scenario/created_scenario.txt", "w") as f:
            f.write(f"scenario={scenario_name}\n")

    elif cmd == "finish":
        if not current_scenario:
            print("no existing scenario found")
            sys.exit(1)

        subprocess.run(["terraform", chdir_arg, "destroy", "-auto-approve"], check=True)

        with open("./created_scenario/created_scenario.txt", "w") as f:
            f.write("scenario=none\n")

        for f in os.listdir(target_dir):
            if f.endswith(".tf"):
                os.remove(os.path.join(target_dir, f))

if __name__ == "__main__":
    main()
