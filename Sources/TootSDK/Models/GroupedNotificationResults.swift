//
//  GroupedNotificationResults.swift
//  TootSDK
//
//  Created by Shihab Mehboob on 20/09/2024.
//  Adapted for TootSDK fork by Pixelfolio
//

import Foundation

public struct GroupedNotificationResults: Codable, Hashable, Sendable {
    public var accounts: [Account]
    public var statuses: [Post]
    public var notificationGroups: [NotificationGroup]

    enum CodingKeys: String, CodingKey {
        case accounts
        case statuses
        case notificationGroups
    }
}

public struct NotificationGroup: Codable, Hashable, Sendable {
    public var groupKey: String
    public var notificationsCount: Int
    public var type: NotificationType
    public var mostRecentNotificationId: Int
    public var sampleAccountIds: [String]
    public var pageMinId: String?
    public var pageMaxId: String?
    public var latestPageNotificationAt: String?
    public var statusId: String?
    public var report: Report?

    enum CodingKeys: String, CodingKey {
        case groupKey
        case notificationsCount
        case type
        case mostRecentNotificationId
        case pageMinId
        case pageMaxId
        case latestPageNotificationAt
        case sampleAccountIds
        case statusId
        case report
    }

    public static func == (lhs: NotificationGroup, rhs: NotificationGroup) -> Bool {
        lhs.mostRecentNotificationId == rhs.mostRecentNotificationId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(mostRecentNotificationId)
    }

    public enum NotificationType: String, Codable, Sendable, CaseIterable {
        /// Someone followed you
        case follow
        /// Someone mentioned you in their post
        case mention
        /// Someone reposted one of your posts
        case repost = "reblog"
        /// Someone favourited one of your posts
        case favourite
        /// A poll you have voted in or created has ended
        case poll
        /// Someone requested to follow you
        case followRequest = "follow_request"
        /// Someone you enabled notifications for has posted a post
        case post = "status"
        /// A post you interacted with has been edited
        case update = "update"
        /// Someone signed up
        case adminSignUp = "admin.sign_up"
        /// A new report has been filed
        case adminReport = "admin.report"
        /// Some of your follow relationships have been severed as a result of a moderation or block event
        case severedRelationships = "severed_relationships"
        /// Moderation warning
        case moderationWarning = "moderation_warning"

        case annualReport = "annual_report"

        /// Returns notification types supported by the given `flavour`.
        public static func supported(by flavour: TootSDKFlavour) -> Set<NotificationType> {
            switch flavour {
            case .mastodon, .sharkey:
                return Set(allCases)
            case .pleroma, .akkoma:
                return [.follow, .mention, .repost, .favourite, .poll, .followRequest, .update, .moderationWarning]
            case .friendica:
                return [.follow, .mention, .repost, .favourite, .poll, .moderationWarning]
            case .pixelfed:
                return [.follow, .mention, .repost, .favourite, .moderationWarning]
            case .firefish:
                return [.follow, .mention, .repost, .poll, .followRequest, .moderationWarning]
            case .catodon, .iceshrimp, .goToSocial:
                // Default to Mastodon-like support for newer flavours
                return Set(allCases)
            }
        }

        /// Returns push notification types supported by the given `flavour`.
        public static func supportedAsPush(by flavour: TootSDKFlavour) -> Set<NotificationType> {
            switch flavour {
            case .mastodon:
                return Set(allCases)
            case .pleroma, .akkoma, .friendica, .sharkey:
                return [.follow, .mention, .repost, .favourite, .poll]
            case .pixelfed, .firefish:
                return []
            case .catodon, .iceshrimp, .goToSocial:
                // Default to basic push support for newer flavours
                return [.follow, .mention, .repost, .favourite, .poll]
            }
        }

        /// Returns true if this notification type is supported by the given `flavour`.
        public func isSupported(by flavour: TootSDKFlavour) -> Bool {
            return Self.supported(by: flavour).contains(self)
        }

        /// Returns true if this notification type is supported as push notification by the given `flavour`.
        public func isSupportedAsPush(by flavour: TootSDKFlavour) -> Bool {
            return Self.supportedAsPush(by: flavour).contains(self)
        }
    }
}

extension GroupedNotificationResults {
    mutating func merge(with newGroupedResults: GroupedNotificationResults) {
        let newNotificationsDict = Dictionary(uniqueKeysWithValues: newGroupedResults.notificationGroups.map { ($0.groupKey, $0) })
        notificationGroups = notificationGroups.filter { oldNotification in
            !newNotificationsDict.keys.contains(oldNotification.groupKey)
        }
        notificationGroups.append(contentsOf: newGroupedResults.notificationGroups)
        notificationGroups.sort { $0.latestPageNotificationAt ?? "" > $1.latestPageNotificationAt ?? "" }
    }
}
