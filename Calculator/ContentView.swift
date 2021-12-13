import SwiftUI

class ViewModel: ObservableObject {
    @Published var taps: [CalculatorButton:Bool] = [:]
    
    let buttons: [[CalculatorButton]] = [
        [.leftParenthesis, .rightParenthesis, .negative, .add],
        [.seven, .eight, .nine, .subtract],
        [.four, .five, .six, .mutliply],
        [.one, .two, .three, .divide],
        [.zero, .decimal, .clear, .equal],
    ]
    
    let buttonSpacing: CGFloat = 15
    let buttonFontSize: CGFloat = 32
    let displayFontSize: CGFloat = 68
    let displayColor = Color.white
    let inputFontSize: CGFloat = 24
    let inputColor = Color.gray
    
    func tapped(button: CalculatorButton) -> Bool {
        if let value = taps[button] {
            return value
        }
        return false
    }
    
    private var arr: [String] = ["0"]
    
    var display: String {
        for str in arr.reversed() {
            if !"()+–x÷".contains(str) {
                return str.first! == "." ? "0\(str)" : str
            }
        }
        
        return "0"
    }
    
    var input: String {
        var value = ""
        
        for str in arr {
            value += "+–x÷".contains(str) ? str : " \(str) "
        }
        
        return value
    }
    
    func onTap(button: CalculatorButton) {
        switch button {
        case .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero:
            let last = arr.last!
            let dis = self.display
            
            if "(+–x÷".contains(last) {
                arr.append(button.rawValue)
                return
            }
            
            if last == "0" {
                arr[arr.count - 1] = button.rawValue
                return
            }
            
            if last == ")" || dis.count > 8 || dis.count == 8 && !dis.contains(".") {
                //error
                return
            }
            
            arr[arr.count - 1].append(button.rawValue)
            break
            
        case .decimal:
            let last = arr.last!
            let dis = self.display
            
            if "(+–x÷".contains(last) {
                arr.append(button.rawValue)
                return
            }

            if last == ")" || dis.count == 8 || dis.contains(".") {
                //error
                return
            }
            
            arr[arr.count - 1].append(button.rawValue)
            break
            
        case .add, .subtract, .mutliply, .divide:
            let last = arr.last!
            
            if "(+–x÷)".contains(last) {
                // error
                return
            }
            
            arr.append(button.rawValue)
            break
            
        case .clear:
            if arr.isEmpty {
                return
            }
            
            arr[arr.count - 1].removeLast()
            
            if arr[arr.count - 1].isEmpty {
                arr.removeLast()
            }
            
            if arr.isEmpty {
                arr.append("0")
            }
            
        case .negative:
            break
            
        case .leftParenthesis:
            
            
            break
            
        case .rightParenthesis:
            break
            
        case .equal:
            break
        }
    }
    
    private func calculate() {
        
    }
    
    func allClear() {
        arr = ["0"]
    }
}

struct ContentView: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .ignoresSafeArea()
            
            let buttonWidth = (UIScreen.main.bounds.width - vm.buttonSpacing * CGFloat(5)) / CGFloat(4)
            
            VStack(alignment: .trailing) {
                HStack {
                    Text(vm.input)
                        .font(.system(size: vm.inputFontSize))
                        .foregroundColor(vm.inputColor)
                        .lineSpacing(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                ScrollView {
                    HStack {
                        Text("123456789")
                            .font(.system(size: vm.displayFontSize))
                            .foregroundColor(vm.displayColor)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                VStack(spacing: vm.buttonSpacing) {
                    ForEach(vm.buttons, id:\.self) { row in
                        HStack(spacing: vm.buttonSpacing) {
                            ForEach(row, id:\.self) { button in
                                Button(action: {
                                    vm.onTap(button: button)
                                }, label: {
                                    Text(button.rawValue)
                                        .font(.system(size: vm.buttonFontSize))
                                        .foregroundColor(button.foregroundColor)
                                })
                                    .frame(width: buttonWidth, height: buttonWidth)
                                    .background(button.backgroundColor)
                                    .clipShape(Circle())
                                    .opacity(vm.tapped(button: button) ? 0.6 : 1.0)
                                    .onLongPressGesture(minimumDuration: .infinity,
                                                        maximumDistance: .infinity,
                                                        pressing: { value in
                                        vm.taps[button] = value
                                    }, perform: {})
                                    .simultaneousGesture(
                                        LongPressGesture(minimumDuration: 0.6)
                                            .onEnded { _ in
                                                if button == .clear {
                                                    vm.allClear()
                                                }
                                            })
                            }
                        }
                    }
                }
            }
            .padding(vm.buttonSpacing)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
