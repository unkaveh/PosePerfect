//
//  SnackbarView.swift
//  PosePerfect AR
//
//  Created by Kaveh.Afroukhteh on 12/19/24.
//
import SwiftUI

public struct SnackbarView: View {
    
    public init(show: Binding<Bool>, bgColor: Color, txtColor: Color, icon: String?, iconColor: Color, message: String) {
        self._show = show
        self.bgColor = bgColor
        self.txtColor = txtColor
        self.icon = icon
        self.iconColor = iconColor
        self.message = message
    }
    
    @Binding public var show: Bool
    public var bgColor: Color
    public var txtColor: Color
    public var icon: String?
    public var iconColor: Color
    public var message: String
    
    public var body: some View {
        if self.show {
            VStack {
                Spacer()
                HStack(alignment: .center, spacing: 12) {
                    if let name = icon {
                        Image(systemName: name)
                            .resizable()
                            .foregroundColor(self.iconColor)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                    
                    Text(message)
                        .foregroundColor(txtColor)
                        .font(.system(size: 14))
                        .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 35)
                .padding(.vertical, 8)
                .background(bgColor)
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .animation(.easeInOut, value: show)
            }
            .transition(.move(edge: .bottom))
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.show = false
                }
            }
        }
    }
}
