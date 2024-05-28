




# SQLiteDebuger Gigantor


https://github.com/a-elnajjar/SQliteDebuger/assets/338095/2da00072-79ee-4399-9aaa-b0ecec078b46


`SQLiteDebuger Gigantor` is an experimental Swift package designed to help developers debug and manage SQLite databases directly within their iOS applications. By leveraging the SQLite3 C API, this package provides a straightforward way to open, switch, and execute SQL statements on SQLite databases. It benefits developers who need to inspect database contents, execute arbitrary queries, and view results in a structured format without leaving their app.

## Features

- Execute SQL statements and display results.

## Requirements

- iOS 14.0+
- Swift 5.5+

## Installation

### Swift Package Manager

To add `SQLiteDebuger` to your Xcode project:

1. Open your Xcode project.
2. Go to `File` > `Add Packages...`.
3. Enter the repository URL for `SQLiteDebuger`:

```
https://github.com/a-elnajjar/SQLiteDebuger.git
```

4. Select the package and add it to your project.

## Usage

Use `SQLiteDebuger` in a SwiftUI application to navigate to a view where you can input a database name and SQL statement, execute it, and display results.

```swift
import SwiftUI
import SQLiteDebuger

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: SQLiteDebugView()) {
                    Text("Open SQLite Debug View")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Main Menu")
        }
    }
}
```

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

## Contributions

Contributions are welcome! Please fork this repository and submit a pull request for any improvements.

## Contact

For any questions or suggestions, please open an issue on the GitHub repository.


### Notes:
1. **Repository URL**: Replace `https://github.com/a-elnajjar/SQLiteDebuger.git` with the actual URL of your GitHub repository.
2. **License**: If you have a `LICENSE` file, ensure it's included. If not, consider adding one.
3. **Contact Information**: Update the contact information and repository URL as needed.

