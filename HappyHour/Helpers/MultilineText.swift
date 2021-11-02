//
//  MultilineText.swift
//  HappyHour
//
//  From  https://stackoverflow.com/questions/63127103/how-to-auto-expand-height-of-nstextview-in-swiftui
//

import SwiftUI

// Wraps the NSTextView in a frame that can interact with SwiftUI
struct MultilineTextField: View {

    private var placeholder: String
    @Binding private var text: String
    @State private var dynamicHeight: CGFloat
    @State private var textIsEmpty: Bool
    var nsFont: NSFont
    private var onCommit: (() -> Void)?

    init (_ placeholder: String = "",
          text: Binding<String>,
          nsFont: NSFont = NSFont.monospacedSystemFont(ofSize: 0, weight: .regular),
          onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        _textIsEmpty = State(wrappedValue: text.wrappedValue.isEmpty)
        self.nsFont = nsFont
        _dynamicHeight = State(initialValue: nsFont.pointSize)
        self.onCommit = onCommit
    }

    var body: some View {
        ZStack {
            NSTextViewWrapper(text: $text,
                              dynamicHeight: $dynamicHeight,
                              textIsEmpty: $textIsEmpty,
                              onCommit: onCommit,
                              nsFont: nsFont)
                .background(placeholderView, alignment: .topLeading)
                // Adaptive frame applied to this NSViewRepresentable
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
        }
    }

    // Background placeholder text matched to default font provided to the NSViewRepresentable
    var placeholderView: some View {
        Text(placeholder)
            .font(.system(size: nsFont.pointSize))
            .opacity(textIsEmpty ? 0.3 : 0)
            .padding(.leading, 5)
            .animation(.easeInOut(duration: 0.15), value: textIsEmpty)
    }
}

// Creates the NSTextView
fileprivate struct NSTextViewWrapper: NSViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    @Binding var textIsEmpty: Bool
    var onCommit: (() -> Void)?
    var nsFont: NSFont

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text,
                           height: $dynamicHeight,
                           textIsEmpty: $textIsEmpty,
                           onCommit: onCommit,
                           nsFont: nsFont)
    }

    func makeNSView(context: NSViewRepresentableContext<NSTextViewWrapper>) -> NSTextView {
        return context.coordinator.textView
    }

    func updateNSView(_ textView: NSTextView, context: NSViewRepresentableContext<NSTextViewWrapper>) {
        NSTextViewWrapper.recalculateHeight(view: textView, result: $dynamicHeight, nsFont: nsFont)
    }

    fileprivate static func recalculateHeight(view: NSView, result: Binding<CGFloat>, nsFont: NSFont) {
        // Uses visibleRect as view.sizeThatFits(CGSize())
        // is not exposed in AppKit, except on NSControls.
        let latestSize = view.visibleRect
        if result.wrappedValue != latestSize.height &&
            // TODO: The view initially renders slightly smaller than needed, then resizes.
            // saw it when adding a new item, then it jiggles when the mouse moves
            // I thought the statement below would prevent the @State dynamicHeight, which
            // sets itself AFTER this view renders, from causing it. Unfortunately that's not
            // the right cause of that redawing bug.
            latestSize.height > (nsFont.pointSize + 1) {
            DispatchQueue.main.async {
                result.wrappedValue = latestSize.height
            }
        }
    }
}

// Maintains the NSTextView's persistence despite redraws
fileprivate final class Coordinator: NSObject, NSTextViewDelegate, NSControlTextEditingDelegate {
    var textView: NSTextView
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    @Binding var textIsEmpty: Bool
    private var onCommit: (() -> Void)?
    var nsFont: NSFont

    init(text: Binding<String>,
         height: Binding<CGFloat>,
         textIsEmpty: Binding<Bool>,
         onCommit: (() -> Void)?,
         nsFont: NSFont) {

        _text = text
        _dynamicHeight = height
        _textIsEmpty = textIsEmpty
        self.onCommit = onCommit
        self.nsFont = nsFont

        textView = NSTextView(frame: .zero)
        textView.isEditable = true
        textView.isSelectable = true

        // Appearance
        textView.usesAdaptiveColorMappingForDarkAppearance = true
        textView.font = nsFont
        textView.textColor = NSColor.textColor
        textView.drawsBackground = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Functionality (more available)
        textView.allowsUndo = true
        textView.isRichText = false
        textView.isAutomaticLinkDetectionEnabled = true
        textView.displaysLinkToolTips = true
        textView.isAutomaticDataDetectionEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextCompletionEnabled = true
        textView.isContinuousSpellCheckingEnabled = false

        super.init()
        // Load data from binding and set font
        textView.string = text.wrappedValue
        textView.textStorage?.font = nsFont
        textView.delegate = self
    }

    func textDidChange(_ notification: Notification) {
        // Recalculate height after every input event
        NSTextViewWrapper.recalculateHeight(view: textView, result: $dynamicHeight, nsFont: nsFont)
        // If ever empty, trigger placeholder text visibility
        if let update = (notification.object as? NSTextView)?.string {
            textIsEmpty = update.isEmpty
        }
    }

    func textDidEndEditing(_ notification: Notification) {
        // Update binding only after editing ends; useful to gate NSManagedObjects
        $text.wrappedValue = textView.string
        if let onCommit = onCommit {
            onCommit()
        }
        // check to see if onCommit modified the binding
        if textView.string != $text.wrappedValue {
            textView.string = $text.wrappedValue
            if let update = (notification.object as? NSTextView)?.string {
                textIsEmpty = update.isEmpty
            }
            NSTextViewWrapper.recalculateHeight(view: textView, result: $dynamicHeight, nsFont: nsFont)
        }
    }
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch (commandSelector) {
        case #selector(NSResponder.insertNewline(_:)):
            // Cause text did end editing on the current text box
            NSApp.keyWindow?.makeFirstResponder(nil)
            // Then reselect ourself
            // TODO: only if this is the "new item" field ?
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.keyWindow?.makeFirstResponder(textView)
            }
            return true
        case #selector(NSResponder.insertTab(_:)):
            NSApp.keyWindow?.makeFirstResponder(nextTextView(textView))
            return true
        case #selector(NSResponder.moveUp(_:)):
            // TODO: dont move if  we're at the top
            guard let cursorCoordinates = cursorCoordinates(textView),
                  cursorCoordinates.minY == 0,
                  let previous = previousTextView(textView) else { return false }
            
            NSApp.keyWindow?.makeFirstResponder(previous)
            let index = previous.characterIndexForInsertion(at: NSPoint(x: cursorCoordinates.minX, y: previous.bounds.size.height - 2));
            previous.setSelectedRange(NSRange(location:index, length:0))
            return true
        case #selector(NSResponder.moveDown(_:)):
            guard let cursorCoordinates = cursorCoordinates(textView),
                  cursorCoordinates.maxY == textView.bounds.maxY,
                  let next = nextTextView(textView) else { return false }
            
            NSApp.keyWindow?.makeFirstResponder(next)
            let index = next.characterIndexForInsertion(at: NSPoint(x: cursorCoordinates.minX, y:0));
            next.setSelectedRange(NSRange(location:index, length:0))
            return true
        default:
            return false
        }
    }
}

fileprivate func previousTextView(_ current: NSTextView) -> NSTextView? {
    var previous: NSView? = current
    while previous != nil {
        previous = previous?.previousKeyView
        if let previous = previous as? NSTextView {
            return previous
        }
    }
    return nil
}

fileprivate func nextTextView(_ current: NSTextView) -> NSTextView? {
    var next: NSView? = current
    while next != nil {
        next = next?.nextKeyView
        if let next = next as? NSTextView {
            return next
        }
    }
    return nil
}

fileprivate func cursorCoordinates(_ textView: NSTextView) -> NSRect? {
    let cursorLocation = NSRange(location:textView.selectedRange().location, length:0);
    guard let container = textView.textContainer else { return nil }
    return textView.layoutManager?.boundingRect(forGlyphRange: cursorLocation, in: container)
}
