import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { GasmixParser } from './common/GasmixParser';
import type { Gasmix } from './common/GasmixParser';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';
type Data = {
  temperature: number;
  moles: number;
  canisterLoaded: BooleanLike;
  gasmixed: Gasmix;
};
export const debugcanmaker = (props, context) => {
	const { act, data } = useBackend<Data>(context);
	const {
	temperature,
	moles,
	canisterLoaded,
	gasmixed
	} = data;
	return (
		<Window width={500} height={460}>
		  <Window.Content scrollable>
			<Section
			  title="Recipient"
			  buttons={
				canisterLoaded ? (
				  <>
					<Button
					  icon="eject"
					  content="Remove Canister"
					  onClick={() => act('removecan')}
					/>
					<NumberInput
					  value={temperature}
					  unit="K"
					  minValue={1}
					  maxValue={355555445453534535355353353534553453545555}
					  step={1}
					  stepPixelSize={2}
					  onChange={(e, value) =>
						act('temperature', {
						  amount: value,
						})
					  }
					/>
					<NumberInput
					  value={moles}
					  unit="mol"
					  minValue={0}
					  maxValue={3555555555555555555555555555555555555555555555555555555555555555555555555555555555555555}
					  step={1}
					  stepPixelSize={2}
					  onChange={(e, value) =>
						act('moles', {
						  amount: value,
						})
					  }
					/>
					<Button
					  icon="plus"
					  content="Input"
					  onClick={() => act('addgas')}
					/>
				  </>
				) : (
				  <Button
					icon="plus"
					content="Create Canister"
					onClick={() => act('makecan')}
				  />
				)
			  }>
			  {canisterLoaded ? (
				<>
					<GasmixParser
						gasmix={gasmixed}
					/>
				</>
			  ) : (
				<Box color="average">No Recipient</Box>
			  )}
			</Section>
		  </Window.Content>
		</Window>
	);
};
