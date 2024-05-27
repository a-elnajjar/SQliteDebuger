//
//  SQLiteDebugView.swift
//
//
//  Created by Abdalla Elnajjar on 2024-05-26.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SQLiteDebugView: View {
    @State private var databaseName: String = ""
    @State private var sqlStatement: String = ""
    @State private var columnNames: [String] = []
    @State private var results: [[String]] = []
    
    public init() {}  // Ensure the initializer is public

    @available(iOS 14.0, *)
    public var body: some View {
        VStack {
            TextField("Enter database name", text: $databaseName)
                .padding()
                .border(Color.gray)
                .frame(width: 300)
            
            TextEditor(text: $sqlStatement)
                .padding()
                .border(Color.gray)
                .frame(width: 300, height: 150)
            
            Button("Execute") {
                executeSQL()
            }
            .padding()
            
            ScrollView {
                if !columnNames.isEmpty && !results.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnNames.count), alignment: .leading) {
                        // Display column names
                        ForEach(columnNames, id: \.self) { columnName in
                            Text(columnName)
                                .fontWeight(.bold)
                                .padding(5)
                                .background(Color.gray.opacity(0.3))
                        }
                        
                        // Display results
                        ForEach(results, id: \.self) { row in
                            ForEach(row, id: \.self) { item in
                                Text(item)
                                    .padding(5)
                                    .background(Color.gray.opacity(0.1))
                            }
                        }
                    }
                    .padding()
                } else {
                    Text("No results")
                        .padding()
                        .frame(width: 300, height: 150)
                        .border(Color.gray)
                }
            }
        }
        .padding()
    }

    private func executeSQL() {
        if !databaseName.isEmpty {
            DatabaseManager.shared.openDatabase(named: databaseName)
        }
        
        switch DatabaseManager.shared.executeSQL(sqlStatement) {
        case .success(let result):
            // Extract column names and row data
            columnNames = Array(result.keys)
            results = [Array(result.values.map { String(describing: $0) })]
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
@available(iOS 14.0, *)
#Preview {
    SQLiteDebugView()
}
