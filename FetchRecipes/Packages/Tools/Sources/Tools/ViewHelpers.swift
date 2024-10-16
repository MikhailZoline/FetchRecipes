//
//  ViewHelpers.swift
//  FetchRecipes
//
//  Created by Mikhail Zoline on 10/16/24.
//

import SwiftUI
import Networking

public struct OffsetPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = .zero
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

public struct ScrollOffsetReader: ViewModifier {
    public var coordSpaceName: String

    public init(name: String ) {
        coordSpaceName = name
    }

    private var scrollOffsetReader: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: geo.frame(in: .named(coordSpaceName)).minY
                )
        }
    }

    public func body(content: Content) -> some View {
        content.background(scrollOffsetReader)
    }
}

public struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize? { .none }

    public static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        guard let nextValue = nextValue() else { return }
        value = nextValue
    }
}

public extension View {
    func readSize(onChange: @escaping (CGSize?) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    //Example:
    //    struct StickyHeader<Header: View>: View {
    //        @ViewBuilder public var header: () -> Header
    //        @State private var headerSize: CGSize = .zero
    //        var body: some View {
    //            header()
    //                .readSize(onChange: {
    //                    headerSize = $0
    //                })
    //      .... do what you need with headerSize
    //        }
    //    }
}

//This readFrame provides frame data directly in frame: parameter
//Example:
//    @State var rect: CGRect = .zero
//    EmptyView().readFrame($rect, .global)

public struct FrameReader: ViewModifier {
    @Binding public var frame: CGRect
    public var coordSpace: CoordinateSpace

    public init(frame: Binding<CGRect>, space: CoordinateSpace ) {
        self._frame = frame
        self.coordSpace = space
    }

    public func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geometryReader -> AnyView in
                    let rect = geometryReader.frame(in: coordSpace)
                    if rect.integral != self.frame.integral {
                        DispatchQueue.main.async {
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            }
    }
}

public extension View {
    func  readFrame(frame: Binding<CGRect>, space: CoordinateSpace) -> some View {
        modifier(FrameReader(frame: frame, space: space))
    }
}

/// Used to draw the rounded border of a view
public struct Bordered: ViewModifier {
    public var cornerRadius: CGFloat
    public var cornerStyle: RoundedCornerStyle
    public var rounded: RoundedRectangle// = RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
    init(cornerRadius: CGFloat = 10, cornerStyle: RoundedCornerStyle = .circular) {
        self.cornerRadius = cornerRadius
        self.cornerStyle = cornerStyle
        self.rounded = RoundedRectangle(cornerRadius: cornerRadius, style: cornerStyle)
    }
    public func body(content: Content) -> some View {
        content
            .overlay(rounded.stroke(lineWidth: 1))
            .background(rounded.fill(.clear))
    }
}

public extension View {
    func bordered(cornerRadius: CGFloat = 10, cornerStyle: RoundedCornerStyle = .circular) -> some View { modifier(Bordered(cornerRadius: cornerRadius, cornerStyle: cornerStyle)) }
}

struct ErrorAlert: ViewModifier {
    @Binding var error: Networking.NetworkingError?
    var isShowingError: Binding<Bool> {
        Binding {
            error != nil
        } set: { _ in
            error = nil
        }
    }
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: isShowingError, error: error) { _ in
            } message: { error in
                if let message = error.errorDescription {
                    Text(message)
                }
            }
    }
}

public extension View {
    func errorAlert(_ error: Binding<Networking.NetworkingError?>) -> some View {
        self.modifier(ErrorAlert(error: error))
    }
}

public class ImageCache{
    static private var cache: [URL: Image] = [:]
    static public subscript(url: URL) -> Image? {
        get {
            ImageCache.cache[url]
        }
        set {
            ImageCache.cache[url] = newValue
        }
    }
}

public struct CacheAsyncImage<Content>: View where Content: View{
    
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    public init(
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ){
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    public var body: some View{
        if let cached = ImageCache[url]{
            let _ = print("cached: \(url.absoluteString)")
            content(.success(cached))
        } else {
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ) {
                cacheAndRender(phase: $0)
            }
        }
    }
    func cacheAndRender(phase: AsyncImagePhase) -> some View{
        if case .success (let image) = phase {
            ImageCache[url] = image
        }
        return content(phase)
    }
}
