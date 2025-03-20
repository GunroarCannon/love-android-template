import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Enter username for registration: ");
        String registeredUsername = scanner.nextLine();

        System.out.print("Enter password for registration: ");
        String registeredPassword = scanner.nextLine();

        System.out.println("Registration successful!");

        boolean isLoggedIn = false;
        while (!isLoggedIn) {
            System.out.print("Enter username for login: ");
            String username = scanner.nextLine();

            System.out.print("Enter password for login: ");
            String password = scanner.nextLine();

            if (username.equals(registeredUsername) && password.equals(registeredPassword)) {
                System.out.println("Login successful! Welcome, " + username);
                isLoggedIn = true;
            } else {
                System.out.println("Invalid username or password. Try again.");
            }
        }

        scanner.close();
    }
}