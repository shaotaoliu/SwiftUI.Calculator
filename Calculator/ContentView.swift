import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .ignoresSafeArea()
            
            let buttonWidth = (UIScreen.main.bounds.width - vm.buttonSpacing * CGFloat(5)) / CGFloat(4)
            
            VStack(alignment: .trailing, spacing: 0) {
                if vm.showPicture {
                    VStack {
                        Image("kids")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(5)
                            .onTapGesture {
                                vm.showPicture = false
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
                else {
                    ScrollViewReader { reader in
                        ScrollView {
                            Text(vm.input)
                                .font(.system(size: vm.inputFontSize))
                                .foregroundColor(vm.inputColor)
                                .lineSpacing(10)
                            //.minimumScaleFactor(0.1)
                                .id("textId")
                                .padding(1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .contentShape(Rectangle())
                        .onChange(of: vm.input, perform: { _ in
                            reader.scrollTo("textId", anchor: .bottom)
                        })
                        .onTapGesture(count: 2) {
                            vm.showPicture = true
                        }
                    }
                }
                
                HStack {
                    Text(vm.result)
                        .font(.system(size: vm.displayFontSize))
                        .foregroundColor(vm.displayColor)
                        .minimumScaleFactor(0.1)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 10)
                .padding(.bottom, 40)
                
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
                                        .frame(width: buttonWidth, height: buttonWidth)
                                        .background(button.backgroundColor)
                                        .clipShape(Circle())
                                })
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
//            .previewInterfaceOrientation(.landscapeLeft)
    }
}
