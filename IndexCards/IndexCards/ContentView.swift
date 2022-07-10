//
//  ContentView.swift
//  IndexCards
//
//  Created by Yannick Opp on 05.04.22.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(Color("AccentBlue"))
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color("CardBG"))]
        UINavigationBar.appearance().tintColor = UIColor(Color("CardBG"))
    }
    
    var body: some View {
        NavigationView {
            ZStack() {
                MainPage()
                    .navigationTitle("IndexCards")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }   .navigationViewStyle(.stack)
    }
}

struct MainPage: View {
    @EnvironmentObject private var icsm: IndexCardSetModel
    @State var showSearchBar: Bool = false
    @State var searchTerm: String = ""
    @State var showCreateSetOverlay: Bool = false
    @State var showDeleteAlert: Bool = false
    @State var goToEdit: Bool = false
    @State var goToLearn: Bool = false
    @State var focusSet: IndexCardSet? = nil
    @State var createSet: Bool = false
    
    var shownSets: [IndexCardSet] {
        if searchTerm.isEmpty {
            return icsm.indexCardSets
        } else {
            return icsm.indexCardSets.filter({$0.title?.contains(searchTerm) ?? false})
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView() {
                VStack(spacing: 10) {
                    ForEach(shownSets) { icSet in
                        ListItemView() {
                            Text(icSet.title ?? "")
                                .font(.system(size: FontSizes.standard.rawValue))
                                .foregroundColor(Color("TextStandard"))
                        }   .alert("Was möchtest du mit \(focusSet?.title ?? "") machen?", isPresented: $showDeleteAlert, actions: {
                            HStack {
                                Button("Editieren", role: .none, action: {
                                    goToEdit.toggle()
                                })
                                Button("Löschen", role: .destructive, action: {
                                    if focusSet != nil {
                                        icsm.deleteSet(focusSet!)
                                        focusSet = nil
                                    }
                                })
                            }
                            Button("Abbrechen", role: .cancel) {}
                        })
                        .onTapGesture {
                            focusSet = icSet
                            goToLearn.toggle()
                        }   .onLongPressGesture() {
                            focusSet = icSet
                            showDeleteAlert.toggle()
                        }
                    }
                }   .padding(.top, 10)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(action: {
                        showCreateSetOverlay = true
                    })  .popover(isPresented: $showCreateSetOverlay) {
                        CreateSetOverlay(isActive: $showCreateSetOverlay, setCreated: $createSet, icSet: $focusSet)
                    }
                }
            }  .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 30))
        }
        .background(Color("MainBG"))
        .background() {
            if focusSet != nil {
                NavigationLink(destination: SetEditPage(icSet: focusSet!), isActive: $createSet) {EmptyView()}
                NavigationLink(destination: SetEditPage(icSet: focusSet!), isActive: $goToEdit) {EmptyView()}
                NavigationLink(destination: LearnSetView(icSet: focusSet!), isActive: $goToLearn)
                    {EmptyView()}
            }
        }   .toolbar() {
            ToolbarItem(placement: .navigationBarTrailing) {
                if showSearchBar {
                    HStack() {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("CardBG"))
                            HStack() {
                                Image(systemName: "magnifyingglass")
                                TextField("Suche", text: $searchTerm)
                                Spacer()
                                Image(systemName: "xmark")
                                    .onTapGesture {
                                        searchTerm = ""
                                        showSearchBar.toggle()
                                    }
                            }   .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        }   .frame(minWidth: 250)
                    }
                } else {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("CardBG"))
                        .onTapGesture {
                            showSearchBar.toggle()
                        }
                }
            }
        }
    }
}

struct CreateSetOverlay: View {
    @EnvironmentObject var icsm: IndexCardSetModel
    @FocusState private var titleInFocus: Bool
    @Binding var isActive: Bool
    @Binding var setCreated: Bool
    @Binding var icSet: IndexCardSet?
    @State private var title: String = ""
    @State private var titleEmptyError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Neues Set erstellen")
                .font(.system(size: FontSizes.title.rawValue))
            if titleEmptyError {
                Text("Titel kann nicht leer sein")
                    .font(.system(size: FontSizes.standard.rawValue))
                    .foregroundColor(Color.red)
            }
            VStack {
                TextField("Titel", text: $title)
                    .focused($titleInFocus)
                    .onSubmit {
                        createSet()
                    }
                    .font(.system(size: FontSizes.standard.rawValue))
                if titleEmptyError {
                    Divider()
                        .background(Color.red)
                }
            }
            HStack() {
                Button("Abbrechen") {
                    isActive.toggle()
                }   .font(.system(size: FontSizes.standard.rawValue))
                Spacer()
                Button("Erstellen") {
                    createSet()
                }   .font(.system(size: FontSizes.standard.rawValue))
            }
        }   .padding(20)
            .frame(minWidth: 150, maxWidth: 300)
            .background(Color("CardBG"))
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.titleInFocus = true
                }
            }
    }
    
    func createSet() {
        if !title.isEmpty {
            icSet = icsm.createSet(title: title)
            setCreated.toggle()
            isActive.toggle()
        } else {
            titleEmptyError = true
        }
    }
}

struct FloatingActionButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            ZStack {
                Circle()
                    .foregroundColor(Color("AccentBlue"))
                    .frame(width: 75, height: 75)
                Image(systemName: "plus")
                    .font(.system(.largeTitle))
                    .foregroundColor(Color("CardBG"))
                    .frame(width: 50)
            }
        })
    }
}

struct SetEditPage: View {
    @EnvironmentObject var icsm: IndexCardSetModel
    @State var icSet: IndexCardSet
    @State private var showCreateCardOverlay: Bool = false
    @State private var showEditCardOverlay: Bool = false
    @State private var icFocus: IndexCard? = nil
    
    var body: some View {
        let cards = icSet.cardsAsArray
        ZStack {
            VStack() {
                ScrollView() {
                    VStack(spacing: 10) {
                        ForEach(cards, id: \.self) { ic in
                            ListItemView(height: 60) {
                                ZStack {
                                    //Needed to be able to set icFocus, it's a bug, don't ask
                                    //Also needed because ForEach doesn't care to update because "nothing in there has changed"
                                    Text(icFocus?.fronttext ?? "").hidden()
                                    VStack(alignment: .leading) {
                                        Text(ic.fronttext ?? "Keine Vorderseite")
                                            .font(.system(size: FontSizes.standard.rawValue))
                                        Divider()
                                        Text(ic.backtext ?? "Keine Rückseite")
                                            .font(.system(size: FontSizes.standard.rawValue))
                                    }
                                }
                            }  .onTapGesture {
                                icFocus = ic
                                showEditCardOverlay.toggle()
                            }
                        }
                    }   .padding(.top, 10)
                        .popover(isPresented: $showEditCardOverlay) {
                            EditCreateCardOverlay(isActive: $showEditCardOverlay, ic: icFocus, icSet: icSet)
                     }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton() {
                        showCreateCardOverlay.toggle()
                    }   .popover(isPresented: $showCreateCardOverlay) {
                        EditCreateCardOverlay(isActive: $showCreateCardOverlay, ic: nil, icSet: icSet)
                    }
                }
            }  .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 30))
        }   .onDisappear() {
            if icSet.cards?.count == 0 {
                icsm.deleteSet(icSet)
            }
        }
        .navigationTitle("\(icSet.title ?? "Unbekanntes Set") bearbeiten")
        .background(Color("MainBG"))
    }
}

struct EditCreateCardOverlay: View {
    @EnvironmentObject private var icsm: IndexCardSetModel
    @Binding var isActive: Bool
    @FocusState private var ftInFocus: Bool
    @FocusState private var btInFocus: Bool
    @State private var fronttext: String
    @State private var backtext: String
    @State var ic: IndexCard?
    let icSet: IndexCardSet
    
    init(isActive: Binding<Bool>, ic: IndexCard?, icSet: IndexCardSet) {
        self._isActive = isActive
        self.ic = ic
        self.icSet = icSet
        self.fronttext = ic?.fronttext ?? ""
        self.backtext = ic?.backtext ?? ""
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(ic == nil ? "Neue Karte erstellen" : "Karte editieren")
                .font(.system(size: FontSizes.title.rawValue))
            TextField("Vorderseite", text: $fronttext)
                .focused($ftInFocus)
                .font(.system(size: FontSizes.standard.rawValue))
                .onSubmit {
                    self.btInFocus = true
                }
            TextField("Rückseite", text: $backtext)
                .focused($btInFocus)
                .font(.system(size: FontSizes.standard.rawValue))
                .onSubmit {
                    if ic == nil {
                        createCard()
                    } else {
                        editCard()
                    }
                }
            HStack() {
                Button("Abbrechen") {
                    isActive.toggle()
                }   .font(.system(size: FontSizes.standard.rawValue))
                Spacer()
                Button(ic == nil ? "Erstellen" : "Fertig") {
                    if ic != nil {
                        editCard()
                    } else {
                        createCard()
                    }
                }   .font(.system(size: FontSizes.standard.rawValue))
            }
        }   .padding(20)
            .frame(minWidth: 150)
            .background(Color("CardBG"))
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.ftInFocus = true
                }
            }
    }
    
    func createCard() {
        if !fronttext.isEmpty && !backtext.isEmpty {
            let card = IndexCard(context: PersistenceController.shared.container.viewContext)
            card.backtext = backtext
            card.fronttext = fronttext
            icSet.addToCards(card)
            icsm.saveSets()
            isActive.toggle()
        }
    }
    
    func editCard() {
        if !fronttext.isEmpty && !backtext.isEmpty && ic != nil {
            ic!.backtext = backtext
            ic!.fronttext = fronttext
            icsm.saveSets()
            isActive.toggle()
        }
    }
}

struct LearnSetView: View {
    let icSet: IndexCardSet
    @Environment(\.dismiss) var dismiss
    private let cards: [IndexCard]
    @State private var currentCardIndex: Int = 0
    @State private var showBack: Bool = false
    @State private var showEndAlert: Bool = false
    
    init(icSet: IndexCardSet) {
        self.icSet = icSet
        cards = icSet.cardsAsArray
    }
    
    var body: some View {
        let currentCard: IndexCard = cards[currentCardIndex]
        VStack {
            HStack {
                Text("Karte: \(currentCardIndex + 1) / \(cards.count)")
                    .font(.system(size: FontSizes.title.rawValue))
                Spacer()
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("CardBG"))
                Text(currentCard.fronttext ?? "Keine Vorderseite")
                    .padding(.all, 20)
            }
            Spacer()
            Divider()
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("CardBG"))
                Text(currentCard.backtext ?? "Keine Rückseite")
                    .padding(.all, 20)
            }.opacity(showBack ? 1 : 0)
            Spacer()
        }   .padding(.all, 20)
            .font(.system(size: FontSizes.standard.rawValue))
            .contentShape(Rectangle())
            .onTapGesture {
                var newIndex = currentCardIndex
                if showBack {
                    newIndex += 1
                }
                if newIndex >= cards.count {
                    showEndAlert.toggle()
                } else {
                    showBack.toggle()
                    currentCardIndex = newIndex
                }
            }
            .navigationTitle("\(icSet.title  ?? "Unbekanntes Set") lernen")
            .alert("Geschafft!", isPresented: $showEndAlert, actions: {
                Button("OK") {
                    dismiss()
                }
            }, message: {Text("Du hast alle Karten dieses Sets durchgelernt.")})
            .background(Color("MainBG"))
    }
}

struct ListItemView<Content: View>: View {
    private let cornerRadius: CGFloat = 10
    var height: CGFloat = 40
    var content: () -> Content
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(Color("CardBG"))
                .overlay() {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color("AccentBlue"))
                }
            content()
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        }   .frame(minHeight: height)
            .shadow(radius: 8.0)
            .padding(.horizontal, 10)
    }
}
