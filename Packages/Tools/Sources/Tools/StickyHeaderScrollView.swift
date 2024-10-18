//
//  StickyHeaderScrollView.swift
//  FetchRecipes
//
//  Created by Mikhail Zoline on 10/16/24.
//

import SwiftUI
//import Tools

struct StickyHeaderScrollView<SummaryHeader: View, ScrollContent: View, StickyHeader: View>: View {
    @ViewBuilder public var scrollContent: () -> ScrollContent
    @ViewBuilder public var summaryHeader: () -> SummaryHeader
    @ViewBuilder public var stickyHeader: () -> StickyHeader
    
    @State private var summaryHeight: CGFloat = .zero
    @Binding private var headerHeight: CGFloat
    @State private var scrollOffset: CGFloat = .zero
    @State private var shouldShowHeader = false
    
    init(
        scrollHeaderHeight: Binding <CGFloat>,
        @ViewBuilder scrollContent: @escaping () -> ScrollContent,
        @ViewBuilder summaryHeader: @escaping () -> SummaryHeader,
        @ViewBuilder stickyHeader: @escaping () -> StickyHeader
    ) {
        _headerHeight = scrollHeaderHeight
        self.scrollContent = scrollContent
        self.summaryHeader = summaryHeader
        self.stickyHeader = stickyHeader
    }
    
    var contentOffset: CGPoint {
        .init(x: 0, y: summaryHeight /*- headerHeight*/)
    }
    
    func onOffsetChange(offset: CGFloat) {
        scrollOffset = offset
        shouldShowHeader = false
        if (-scrollOffset + headerHeight) > summaryHeight {
            shouldShowHeader.toggle()
        }
    }
    
    func viewDidAppear() {
        onOffsetChange(offset: scrollOffset)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                ZStack {
                    GeometryReader { geo in
                        summaryHeader()
                            .readSize {
                                if let size = $0 {
                                    summaryHeight = size.height
                                }
                            }
                            .offset(y: geo.frame(in: .global).origin.y < 0 ? abs(geo.frame(in: .global).origin.y) : -geo.frame(in: .global).origin.y)
                    }
                    scrollContent()
                        .offset(y: contentOffset.y)
                        .padding(.bottom, contentOffset.y)
                }
                .modifier(ScrollOffsetReader(name: "scrollSpace"))
                .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChange)
                .onAppear(perform: viewDidAppear)
            }
            .edgesIgnoringSafeArea(.top)
            
            if shouldShowHeader {
                stickyHeader()
                    .transition(.move(edge: .top).animation(.easeInOut(duration: 0.4)))
                    .ignoresSafeArea(edges: .top)
            }
        }
    }
}

struct StickyHeaderScrollViewDemoContent: View {
    @State var buttonBarHeight: CGFloat = 80.0
    
    var content: some View {
        VStack(spacing: -8) {
            self.stickyHeader
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.blue)
                .frame(height: 2_200)
                .padding([.horizontal, .top])
                .overlay(Text("SCROLL CONTENT")
                    .font(.system(size: 70, weight: .black))
                    .foregroundColor(.white)
                    .opacity(0.8))
            
        }
    }
    
    var header: some View {
        RoundedRectangle(cornerRadius: 30, style: .circular)
            .fill(.red)
            .frame(height: 320)
            .padding([.horizontal, .top])
            .overlay(Text("Summary HEADER")
                .font(.system(size: 70, weight: .black))
                .foregroundColor(.white)
                .opacity(0.8))
    }
    
    var stickyHeader: some View {
        RoundedRectangle(cornerRadius: 30, style: .circular)
            .fill(.green)
            .frame(height: 70)
            .padding([.horizontal, .top])
            .overlay(Text("STICKY HEADER")
                .font(.system(size: 50, weight: .black))
                .foregroundColor(.white)
                .opacity(0.8))
    }
    
    var body: some View {
        StickyHeaderScrollView(
            scrollHeaderHeight: $buttonBarHeight,
            scrollContent: {
                content
            }, summaryHeader: {
                header
            }, stickyHeader: {
                stickyHeader
            }
        )
    }
}

struct StickyHeaderScrollView_Previews: PreviewProvider {
    static var previews: some View {
        StickyHeaderScrollViewDemoContent()
            .edgesIgnoringSafeArea(.vertical)
            .background(Color.white)
    }
}
