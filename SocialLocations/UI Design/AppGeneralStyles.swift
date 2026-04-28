//
//  TextStyles.swift
//  SocialLocations
//
//  Created by Bernarda Perez De Nucci on 4/28/26.
//

import SwiftUI

// LOG IN AND SIGN UP STYLES
struct LogSignTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appGreen.opacity(0.3), lineWidth: 1.5)
            )
    }
}

// SHEET TEXT STYLES
struct SheetTitleStyle:  ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 45, weight: .black, design: .rounded))
            .foregroundStyle(Color.textTitles)
    }
}

struct SheetSubtitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.bold())
            .foregroundStyle(Color.textMain)
    }
}

struct SheetTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 23))
            .foregroundStyle(Color.textMain)
            
    }
}

// SHEET SECTIONS STYLES
struct SheetTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.backgroundSecondary)
            .cornerRadius(12)
    }
}

struct SheetCategoryTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 140)
            .padding(.horizontal, 2)
            .padding(.vertical, 8)
            .background(Color.backgroundSecondary)
            .cornerRadius(12)
    }
}

struct SheetRatingTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 2)
            .padding(.vertical, 12)
            .background(Color.backgroundSecondary)
            .cornerRadius(12)
    }
}

struct SheetStarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.appGreen)
            .font(.title3)
    }
}

struct SheetCapsuleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.appGreen.opacity(0.1))
            .foregroundStyle(Color.appGreen)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.appGreen.opacity(0.25), lineWidth: 1)
            )
    }
}

extension View {
    func logSignTextFieldStyle() -> some View { modifier(LogSignTextFieldStyle()) }
    func sheetSubtitleStyle() -> some View { modifier(SheetSubtitleStyle()) }
    func sheetTitleStyle() -> some View { modifier(SheetTitleStyle()) }
    func sheetTextStyle() -> some View { modifier(SheetTextStyle()) }
    func sheetTextFieldStyle() -> some View { modifier(SheetTextFieldStyle()) }
    func sheetCategoryTextFieldStyle() -> some View { modifier(SheetCategoryTextFieldStyle()) }
    func sheetRatingTextFieldStyle() -> some View { modifier(SheetRatingTextFieldStyle()) }
    func sheetStarStyle() -> some View { modifier(SheetStarStyle()) }
    func sheetCapsuleStyle() -> some View { modifier(SheetCapsuleStyle()) }
}
    

// CARD SECTION STYLES




