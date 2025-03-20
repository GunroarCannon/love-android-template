#include <iostream>
#include <string>

int main() {
    std::string registeredUsername, registeredPassword;
    std::cout << "Enter username for registration: ";
    std::getline(std::cin, registeredUsername);

    std::cout << "Enter password for registration: ";
    std::getline(std::cin, registeredPassword);

    std::cout << "Registration successful!" << std::endl;

    bool isLoggedIn = false;
    while (!isLoggedIn) {
        std::string username, password;
        std::cout << "Enter username for login: ";
        std::getline(std::cin, username);

        std::cout << "Enter password for login: ";
        std::getline(std::cin, password);

        if (username == registeredUsername && password == registeredPassword) {
            std::cout << "Login successful! Welcome, " << username << std::endl;
            isLoggedIn = true;
        } else {
            std::cout << "Invalid username or password. Try again." << std::endl;
        }
    }

    return 0;
}