import KiwiDomain
import SwiftUI

/// Chooses a Pet's species, Cat, Dog or Other, in a segmented control.
struct PetSpeciesPicker: View {
  @Binding var species: PetSpecies

  var body: some View {
    Picker("Species", selection: $species) {
      ForEach(PetSpecies.allCases, id: \.self) { species in
        Text(species.rawValue).tag(species)
      }
    }
    .pickerStyle(.segmented)
  }
}
