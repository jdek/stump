import { useRouter } from 'expo-router'
import { View } from 'react-native'

import { icons } from '~/components/ui'

import AppSettingsRow from '../AppSettingsRow'

const { ChevronRight } = icons

export default function ReaderSettingsLink() {
	const router = useRouter()
	return (
		<AppSettingsRow
			icon="Settings2"
			title="Settings"
			onPress={() => router.push('/settings/reader')}
			isLink
			divide={false}
		>
			<View className="flex flex-row items-center gap-2">
				<ChevronRight size={20} className="text-foreground-muted" />
			</View>
		</AppSettingsRow>
	)
}
