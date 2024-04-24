import SwiftUI

// Define a struct to represent an income entry
struct IncomeEntry: Identifiable {
    let id = UUID()
    var amount: Double
    var currency: String
    var date: Date
}

// ViewModel to manage income entries
class IncomeTrackerViewModel: ObservableObject {
    @Published var incomeEntries: [IncomeEntry] = []
    
    func addIncome(amount: Double, currency: String, date: Date) {
        let newEntry = IncomeEntry(amount: amount, currency: currency, date: date)
        incomeEntries.append(newEntry)
    }
    
    func deleteIncome(at offsets: IndexSet) {
        incomeEntries.remove(atOffsets: offsets)
    }
}



struct AddExpenseView: View {
    @ObservedObject var viewModel: IncomeTrackerViewModel
    @Binding var isShowing: Bool
    @State private var amount = ""
    @State private var date = Date()
    @State private var selectedCurrency = "USD"
    
    // List of available currency types
    let currencies = ["USD", "EUR", "TRY"]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Amount")) {
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Section(header: Text("Currency")) {
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header: Text("Date")) {
                        DatePicker("", selection: $date, displayedComponents: .date)
                    }
                }
                
                Button("Add Expense") {
                    guard let amount = Double(amount) else { return }
                    let expenseAmount = -amount // Negative amount for expenses
                    viewModel.addIncome(amount: expenseAmount, currency: selectedCurrency, date: date)
                    isShowing.toggle()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red) // Use a different color for expense button
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
            .navigationTitle("Add Expense")
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = IncomeTrackerViewModel()
    @State private var isShowingAddIncome = false
    @State private var isShowingAddExpense = false
    @State private var isShowingBalance = false // New state variable for showing balance
    
    var totalBalance: Double {
        viewModel.incomeEntries.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.incomeEntries) { entry in
                        IncomeRowView(entry: entry)
                    }
                    .onDelete(perform: viewModel.deleteIncome)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Cash Wave")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                isShowingAddIncome.toggle()
                            }) {
                                Image(systemName: "plus")
                            }
                            Button(action: {
                                isShowingAddExpense.toggle()
                            }) {
                                Image(systemName: "minus")
                            }
                            Button(action: {
                                isShowingBalance.toggle() // Toggle the state to show/hide balance
                            }) {
                                Image(systemName: "dollarsign.circle") // Use an appropriate icon for balance
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddIncome) {
                AddIncomeView(viewModel: viewModel, isShowing: $isShowingAddIncome)
            }
            .sheet(isPresented: $isShowingAddExpense) {
                AddExpenseView(viewModel: viewModel, isShowing: $isShowingAddExpense)
            }
            .overlay(
                // Overlay to display balance when isShowingBalance is true
                Group {
                    if isShowingBalance {
                        VStack {
                            Spacer()
                            Text("Total Balance: \(totalBalance, specifier: "%.2f")")
                                .font(.headline)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .padding()
                        }
                    }
                }
            )
        }
    }
}

// View for displaying an income entry
struct IncomeRowView: View {
    let entry: IncomeEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(entry.currency) \(String(format: "%.2f", entry.amount))")
                    .font(.headline)
                Text("\(entry.date, formatter: DateFormatter.shortDate)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// View for adding a new income entry
struct AddIncomeView: View {
    @ObservedObject var viewModel: IncomeTrackerViewModel
    @Binding var isShowing: Bool
    @State private var amount = ""
    @State private var date = Date()
    @State private var selectedCurrency = "USD"
    
    // List of available currency types
    let currencies = ["USD", "EUR", "TRY"]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Amount")) {
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Section(header: Text("Currency")) {
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header: Text("Date")) {
                        DatePicker("", selection: $date, displayedComponents: .date)
                    }
                }
                
                Button("Add Income") {
                    guard let amount = Double(amount) else { return }
                    viewModel.addIncome(amount: amount, currency: selectedCurrency, date: date)
                    isShowing.toggle()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }
            .navigationTitle("Add Income")
        }
    }
}

// Extension for formatting dates
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

