def main():
    registered_username = input("Enter username for registration: ")
    registered_password = input("Enter password for registration: ")

    print("Registration successful!")

    logged_in = False
    while not logged_in:
        username = input("Enter username for login: ")
        password = input("Enter password for login: ")

        if username == registered_username and password == registered_password:
            print(f"Login successful! Welcome, {username}")
            logged_in = True
        else:
            print("Invalid username or password. Try again.")


main()