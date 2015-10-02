@python -x "%~f0" %* & exit /b
# coding: utf-8

"""
This is comment, you do not have to specify using REM

Check out this long list: 
http://stackoverflow.com/questions/245395/hidden-features-of-windows-batch-files

This is meant to be a Python file
"""

import argparse
import shutil
import stat
import subprocess
import os
import sys
import xml.etree.ElementTree as ET


parser = argparse.ArgumentParser()
parser.add_argument("-a", "--agents", help="agents to update",
                    action="append")
parser.add_argument("-l", "--list-agents", action="store_true",
                    help="list all agents that can be updated")
parser.add_argument("-b", "--invoke-obuild", action="store_true",
                    help="invoke obuild before updating the deployment")
parser.add_argument("-v", "--verbose", action="store_true",
                    help="verbose mode")

args = parser.parse_args()


def get_deployment_dir():
    iis_config = subprocess.check_output((r'C:\Windows\System32\inetsrv\appcmd.exe', 'list', 'config'))
    tree = ET.fromstringlist(('<iis.config>', iis_config, '</iis.config>'))

    dirs = [
        os.path.join(elem.get('directory'), '..')
        for elem in tree.findall(".//traceFailedRequestsLogging[@enabled='true']")
    ]

    if args.verbose:
        print("found deployment directories", dirs)

    if not dirs:
        print("No deployment folders found, exit")
        sys.exit(0)

    deployment_dir = dirs[0]

    while os.path.basename(deployment_dir) != 'directory':

        parent_dir = os.path.dirname(deployment_dir)

        if deployment_dir == parent_dir:
            print('Could not find the root of the deployment directory')
            return

        deployment_dir = parent_dir

    return deployment_dir


def update_deployed_file(original_file_path, deployed_file_path):
    if not original_file_path.exists():
        print("Can't find original file for `{}`".format(deployed_file_path))
        return

    if original_file_path.stat().st_mtime <= deployed_file_path.stat().st_mtime:
        return

    print('`{}` -> `{}`'.format(original_file_path, deployed_file_path))

    try:
        shutil.copy(str(original_file_path), str(deployed_file_path))
    except PermissionError as exc:
        orig_mode = deployed_file_path.stat().st_mode
        deployed_file_path.chmod(stat.S_IWRITE)

        try:
            shutil.copy(str(original_file_path), str(deployed_file_path))
        except PermissionError:
            print(exc)
        finally:
            deployed_file_path.chmod(orig_mode)



def main():

    deployment_dir = get_deployment_dir()

    if not deployment_dir:
        print('No local deployments detected; aborting')
        exit(1)

    print('Found deployment directory:', deployment_dir)

    target_root = os.environ['TARGETROOT']
    install_root = os.environ['INSTALLROOT']
    print target_root
    print install_root

    available_agents_dir = os.path.join(install_root, r'x64\debug\devhosted_omex\en-us\Agents')
    deployed_agents_dir = os.path.join(deployment_dir, r'AppDir\Current')

    print available_agents_dir
    print deployed_agents_dir

    available_agents = set(agent_dir.name for agent_dir in available_agents_dir.iterdir())
    deployed_agents = set(agent_dir.name for agent_dir in deployed_agents_dir.iterdir())
    selected_agents = available_agents & deployed_agents

    if args.list_agents:
        print('Agents that can be updated:\n\t{}'.format('\n\t'.join(sorted(selected_agents))))
        exit(0)

    if args.agents:
        cli_agents = set(args.agents)

        if cli_agents - selected_agents:
            print('Agents not found:', ', '.join(cli_agents - selected_agents))
            exit(2)

        selected_agents = selected_agents & cli_agents
    else:
        print('No agents selected for update (use `-a AgentName` to '
              'specify what agents need to be updated)')
        exit(3)

    if args.invoke_obuild:
        subprocess.check_call(["obuild"], shell=True)

    for agent_id in selected_agents:
        print('Updating agent `{}`'.format(agent_id))
        print('Copying files:')

        for root, dirs, files in os.walk(str(deployed_agents_dir / agent_id)):
            root_dir = Path(root)

            for file_path in files:
                deployed_file_path = root_dir / file_path
                relative_file_path = deployed_file_path.relative_to(deployed_agents_dir)
                original_file_path = available_agents_dir / relative_file_path

                update_deployed_file(original_file_path, deployed_file_path)


if __name__ == '__main__':
    main()
