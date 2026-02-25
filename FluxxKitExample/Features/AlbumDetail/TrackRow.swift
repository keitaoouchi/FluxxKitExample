import SwiftUI

struct TrackRow: View {
    let track: Track
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                if isPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(Color.spotifyGreen)
                        .frame(width: 24)
                } else {
                    Text("\(track.trackNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.body)
                        .foregroundStyle(isPlaying ? Color.spotifyGreen : .primary)
                        .lineLimit(1)
                }

                Spacer()

                Text(track.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if track.previewUrl != nil {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .foregroundStyle(Color.spotifyGreen)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
