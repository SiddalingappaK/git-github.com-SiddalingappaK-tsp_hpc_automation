#!/bin/bash

import os
import sys
import json
import subprocess

SCRIPTS_PATH='scripts'
APP_JSON=['stream.json', 'hpl.json', 'hpcg.json', 'cloverleaf.json', 'lammps.json', 'gromacs.json']
APP = ['stream', 'hpl', 'hpcg', 'cloverleaf', 'lammps', 'gromacs']

class Run_class():
    """
    This is Class
    """
    def __init__(self):
        self.action1 = ""
        self.action2 = ""
        self.data = {}
        self.lists = []
        self.file1 = ""

    def read_json(self):
        """This function will read json"""
        try:
            f = open (self.file1,"r")
            self.data = json.loads(f.read())
            list5 = [[i, j] for i,j in self.data.items()]
            list6 = []
            for j in range(0,len(list5)):
                list6.append(list5[j][0])
                list6.append(list5[j][1])
            if (list6[0] == "app") and (list6[1] in APP):
                self.lists = list6[1:]
            else:
                print("Invalid application name provided")
                sys.exit(1)
            f.close()
            return 0
        except FileNotFoundError as err:
            print(err)
            sys.exit(1)
        except Exception as e:
            print("Issue while reading json file data. ")
            sys.exit(1)

    def hpl_call(self):
        """This fucntiion will perform Binary Building of applications"""
        try:
            self.read_json()
            a = "./"+str(self.lists[0])+".sh"
            lst1 = []
            lst1.append(a)
            lst1.extend(self.lists[1:])
            os.chdir(SCRIPTS_PATH)
            out = subprocess.call(lst1)
            if out != 0:
                print("\nUnable to complete {} binary building".format(self.lists[0]))
                sys.exit(1)
            return 0
        except subprocess.CalledProcessError as err:
            print(" ")
            print(err.output)
            sys.exit(1)
        except Exception as e:
            print("\nIssue while executing the script.")
            sys.exit(1)


def  help_fn():
    """
    This function will display the actions and their corresponding operartions
    """
    print("Action:                   Description\n")
    print("--app=stream.json         Building Stream binary")
    print("--app=hpl.json            Building Hpl binary")
    print("--app=hpcg.json           Building Hpcg binary")
    print("--app=cloverleaf.json     Building Cloverleaf binary")
    print("--app=lammps.json         Building Lammps binary")
    print("--app=gromacs.json        Building Gromacs binary\n")
    print("--help                    To display actions and descriptions\n")

def main():
    try:
        if len(sys.argv) != 2:
            print("\nInvalid command line arguments provided\nPlease choose valid actions\n")
            help_fn()
            sys.exit(1)
        obj1 = Run_class()
        data_cmd = sys.argv[1].split("=")
        obj1.action1 = data_cmd[0].strip()
        obj1.action2 = data_cmd[1].strip()
        if (obj1.action1 == "--app") and (obj1.action2 in APP_JSON):
            obj1.file1 = obj1.action2
            obj1.hpl_call()
        else:
            print("\nInvalid action provided\nPlease choose valid actions\n")
            help_fn()
            sys.exit(1)
    except Exception:
        print("\nInvalid action provided\nPlease choose valid actions\n")
        help_fn()
        sys.exit(1)


if __name__ == "__main__":
    main()
sys.exit(0)

