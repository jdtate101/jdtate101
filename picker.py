import subprocess

def run_script_1():
    subprocess.call(["bash", "gke-db-demo.sh"])

def run_script_2():
    subprocess.call(["bash", "gke-hol.sh"])

def run_script_3():
    subprocess.call(["bash", "k3s-db-demo.sh"])

def run_script_4():
    subprocess.call(["bash", "se-demo-eks.sh"])

def main(): 
    print("_____  ___                ___                            __    ____  _____ ")
    print("|    |/ _|____    _______/  |_  ____   ____             |  | _/_   \   _  \ ")  
    print("|      < \__  \  /  ___/\   __\/ __ \ /    \    ______  |  |/ /|   /  /_\  \ ")
    print("|    |  \ / __ \_\___ \  |  | \  ___/|   |  \  /_____/  |    < |   \  \_/   \ ")
    print("|____|__ (____  /____  > |__|  \___  >___|  /           |__|_ \|___|\_____  / ")
    print("        \/    \/     \/            \/     \/                 \/           \/ ")
    print("Welcome to the script runner!")
    print("Please select an option:")
    print("1. DB Demo GKE Context")
    print("2. Veeam Kasten HOL GKE Context")
    print("3. DB Demo - SSH to K3S in GCP")
    print("4. SE Demo on EKS")
    choice = int(input())
    if choice == 1:
        run_script_1()
    elif choice == 2:
        run_script_2()
    elif choice == 3:
        run_script_3()
    elif choice == 4:
        run_script_4()
    else:
        print("Invalid option. Please try again.")

if __name__ == "__main__":
    main()
