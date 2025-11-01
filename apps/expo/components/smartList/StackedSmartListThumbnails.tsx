import { useSuspenseGraphQL } from '@stump/client'
import { graphql } from '@stump/graphql'

import { useActiveServer } from '../activeServer'
import StackedEffectThumbnail from '../StackedEffectThumbnail'

const query = graphql(`
	query StackedSmartListThumbnails {
		smartLists {
			id
			thumbnail {
				url
			}
		}
	}
`)

export default function StackedSmartListThumbnails() {
	const {
		activeServer: { id: serverID },
	} = useActiveServer()

	const {
		data: {
			smartLists: [list],
		},
	} = useSuspenseGraphQL(query, ['stackedSmartListThumbnails'])
	const listID = list?.id || ''

	if (!listID) {
		return null
	}

	return (
		<StackedEffectThumbnail
			label="Smart Lists"
			uri={list.thumbnail.url}
			href={`/server/${serverID}/smart-lists`}
		/>
	)
}
