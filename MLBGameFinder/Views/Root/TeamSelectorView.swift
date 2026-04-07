import SwiftUI

// MARK: - TeamSelectorView

struct TeamSelectorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TeamSelectionViewModel?
    @Environment(\.teamTheme) private var theme

    private let divisionOrder: [Division] = [
        .alEast, .alCentral, .alWest,
        .nlEast, .nlCentral, .nlWest
    ]

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    List {
                        ForEach(divisionOrder, id: \.self) { division in
                            if let teams = vm.filteredTeamsByDivision[division], !teams.isEmpty {
                                Section(division.rawValue) {
                                    ForEach(teams) { team in
                                        teamRow(team: team, isSelected: team.id == vm.selectedTeamId)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                vm.selectTeam(team)
                                                dismiss()
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: Binding(
                        get: { vm.searchText },
                        set: { vm.searchText = $0 }
                    ), prompt: "Search teams")
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Select Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TeamSelectionViewModel(appState: appState)
            }
        }
    }

    @ViewBuilder
    private func teamRow(team: MlbTeam, isSelected: Bool) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: team.primaryHex))
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .font(.body)
                Text(team.abbreviation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(theme.primary)
                    .fontWeight(.semibold)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(team.name)\(isSelected ? ", selected" : "")")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    TeamSelectorView()
        .environment(AppState())
}
