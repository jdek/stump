import { Linking, View } from 'react-native'

import { icons, Text } from '../ui'
import AppSettingsRow from './AppSettingsRow'

const { ArrowUpRight } = icons

export default function ContactInformation() {
	return (
		<View>
			<Text className="mb-3 text-foreground-muted">Contact</Text>

			<AppSettingsRow
				icon="Mail"
				title="Email"
				onPress={() => Linking.openURL('mailto:aaronleopold1221@gmail.com')}
				isLink
			>
				<ArrowUpRight size={20} className="text-foreground-muted" />
			</AppSettingsRow>

			<AppSettingsRow
				icon="Discord"
				title="Discord"
				isLink
				onPress={() => Linking.openURL('https://discord.gg/63Ybb7J3as')}
			>
				<ArrowUpRight size={20} className="text-foreground-muted" />
			</AppSettingsRow>

			<AppSettingsRow
				icon="GitHub"
				title="GitHub"
				isLink
				onPress={() => Linking.openURL('https://github.com/stumpapp/stump/issues/new/choose')}
			>
				<ArrowUpRight size={20} className="text-foreground-muted" />
			</AppSettingsRow>
		</View>
	)
}
