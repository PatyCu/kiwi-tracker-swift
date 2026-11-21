import Foundation
import Supabase

internal enum PublicSchema {
  internal struct CalendarEventsSelect: Codable, Hashable, Sendable {
    internal let createdAt: String
    internal let description: String?
    internal let endsAt: String
    internal let id: UUID
    internal let location: String?
    internal let petId: UUID
    internal let startsAt: String
    internal let title: String
    internal enum CodingKeys: String, CodingKey {
      case createdAt = "created_at"
      case description = "description"
      case endsAt = "ends_at"
      case id = "id"
      case location = "location"
      case petId = "pet_id"
      case startsAt = "starts_at"
      case title = "title"
    }
  }
  internal struct CalendarEventsInsert: Codable, Hashable, Sendable {
    internal let createdAt: String?
    internal let description: String?
    internal let endsAt: String
    internal let id: UUID?
    internal let location: String?
    internal let petId: UUID
    internal let startsAt: String
    internal let title: String
    internal enum CodingKeys: String, CodingKey {
      case createdAt = "created_at"
      case description = "description"
      case endsAt = "ends_at"
      case id = "id"
      case location = "location"
      case petId = "pet_id"
      case startsAt = "starts_at"
      case title = "title"
    }
  }
  internal struct CalendarEventsUpdate: Codable, Hashable, Sendable {
    internal let createdAt: String?
    internal let description: String?
    internal let endsAt: String?
    internal let id: UUID?
    internal let location: String?
    internal let petId: UUID?
    internal let startsAt: String?
    internal let title: String?
    internal enum CodingKeys: String, CodingKey {
      case createdAt = "created_at"
      case description = "description"
      case endsAt = "ends_at"
      case id = "id"
      case location = "location"
      case petId = "pet_id"
      case startsAt = "starts_at"
      case title = "title"
    }
  }
  internal struct HouseholdMembersSelect: Codable, Hashable, Sendable {
    internal let displayName: String
    internal let householdId: UUID
    internal let id: UUID
    internal let userId: UUID
    internal enum CodingKeys: String, CodingKey {
      case displayName = "display_name"
      case householdId = "household_id"
      case id = "id"
      case userId = "user_id"
    }
  }
  internal struct HouseholdMembersInsert: Codable, Hashable, Sendable {
    internal let displayName: String
    internal let householdId: UUID
    internal let id: UUID?
    internal let userId: UUID
    internal enum CodingKeys: String, CodingKey {
      case displayName = "display_name"
      case householdId = "household_id"
      case id = "id"
      case userId = "user_id"
    }
  }
  internal struct HouseholdMembersUpdate: Codable, Hashable, Sendable {
    internal let displayName: String?
    internal let householdId: UUID?
    internal let id: UUID?
    internal let userId: UUID?
    internal enum CodingKeys: String, CodingKey {
      case displayName = "display_name"
      case householdId = "household_id"
      case id = "id"
      case userId = "user_id"
    }
  }
  internal struct HouseholdsSelect: Codable, Hashable, Sendable {
    internal let alias: String
    internal let id: UUID
    internal enum CodingKeys: String, CodingKey {
      case alias = "alias"
      case id = "id"
    }
  }
  internal struct HouseholdsInsert: Codable, Hashable, Sendable {
    internal let alias: String
    internal let id: UUID?
    internal enum CodingKeys: String, CodingKey {
      case alias = "alias"
      case id = "id"
    }
  }
  internal struct HouseholdsUpdate: Codable, Hashable, Sendable {
    internal let alias: String?
    internal let id: UUID?
    internal enum CodingKeys: String, CodingKey {
      case alias = "alias"
      case id = "id"
    }
  }
  internal struct PetEventsSelect: Codable, Hashable, Sendable {
    internal let createdAt: String
    internal let dietChange: AnyJSON?
    internal let id: UUID
    internal let note: String?
    internal let occurredAt: String
    internal let petId: UUID
    internal let symptom: String?
    internal let title: String?
    internal let type: String
    internal enum CodingKeys: String, CodingKey {
      case createdAt = "created_at"
      case dietChange = "diet_change"
      case id = "id"
      case note = "note"
      case occurredAt = "occurred_at"
      case petId = "pet_id"
      case symptom = "symptom"
      case title = "title"
      case type = "type"
    }
  }
  internal struct PetEventsInsert: Codable, Hashable, Sendable {
    internal let createdAt: String?
    internal let dietChange: AnyJSON?
    internal let id: UUID?
    internal let note: String?
    internal let occurredAt: String
    internal let petId: UUID
    internal let symptom: String?
    internal let title: String?
    internal let type: String
    internal enum CodingKeys: String, CodingKey {
      case createdAt = "created_at"
      case dietChange = "diet_change"
      case id = "id"
      case note = "note"
      case occurredAt = "occurred_at"
      case petId = "pet_id"
      case symptom = "symptom"
      case title = "title"
      case type = "type"
    }
  }
  internal struct PetEventsUpdate: Codable, Hashable, Sendable {
    internal let createdAt: String?
    internal let dietChange: AnyJSON?
    internal let id: UUID?
    internal let note: String?
    internal let occurredAt: String?
    internal let petId: UUID?
    internal let symptom: String?
    internal let title: String?
    internal let type: String?
    internal enum CodingKeys: String, CodingKey {
      case createdAt = "created_at"
      case dietChange = "diet_change"
      case id = "id"
      case note = "note"
      case occurredAt = "occurred_at"
      case petId = "pet_id"
      case symptom = "symptom"
      case title = "title"
      case type = "type"
    }
  }
  internal struct PetsSelect: Codable, Hashable, Sendable {
    internal let birthDate: String?
    internal let breed: String?
    internal let householdId: UUID
    internal let id: UUID
    internal let name: String
    internal let photoPath: String?
    internal let species: String
    internal enum CodingKeys: String, CodingKey {
      case birthDate = "birth_date"
      case breed = "breed"
      case householdId = "household_id"
      case id = "id"
      case name = "name"
      case photoPath = "photo_path"
      case species = "species"
    }
  }
  internal struct PetsInsert: Codable, Hashable, Sendable {
    internal let birthDate: String?
    internal let breed: String?
    internal let householdId: UUID
    internal let id: UUID?
    internal let name: String
    internal let photoPath: String?
    internal let species: String
    internal enum CodingKeys: String, CodingKey {
      case birthDate = "birth_date"
      case breed = "breed"
      case householdId = "household_id"
      case id = "id"
      case name = "name"
      case photoPath = "photo_path"
      case species = "species"
    }
  }
  internal struct PetsUpdate: Codable, Hashable, Sendable {
    internal let birthDate: String?
    internal let breed: String?
    internal let householdId: UUID?
    internal let id: UUID?
    internal let name: String?
    internal let photoPath: String?
    internal let species: String?
    internal enum CodingKeys: String, CodingKey {
      case birthDate = "birth_date"
      case breed = "breed"
      case householdId = "household_id"
      case id = "id"
      case name = "name"
      case photoPath = "photo_path"
      case species = "species"
    }
  }
}
