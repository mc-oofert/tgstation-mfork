import { BooleanLike } from 'common/react';
import { Component } from 'react';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dimmer,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Icon,
} from '../../components';
import { fetchRetry } from '../../http';
import { Window } from '../../layouts';
import { GenericUplink, Item } from './GenericUplink';
import { PrimaryObjectiveMenu } from './PrimaryObjectiveMenu';
import { Tooltip } from 'tgui-core/components';

type UplinkItem = {
  id: string;
  name: string;
  icon: string;
  icon_state: string;
  cost: number;
  desc: string;
  category: string;
  purchasable_from: number;
  restricted: BooleanLike;
  limited_stock: number;
  stock_key: string;
  restricted_roles: string;
  restricted_species: string;
  progression_minimum: number;
  cost_override_string: string;
  lock_other_purchases: BooleanLike;
  ref?: string;
};

type UplinkData = {
  telecrystals: number;
  lockable: BooleanLike;
  uplink_flag: number;
  assigned_role: string;
  assigned_species: string;
  debug: BooleanLike;
  extra_purchasable: UplinkItem[];
  extra_purchasable_stock: {
    [key: string]: number;
  };
  current_stock: {
    [key: string]: number;
  };

  has_objectives: BooleanLike;
  primary_objectives: {
    [key: number]: string;
  };
  purchased_items: number;
  shop_locked: BooleanLike;
  can_renegotiate: BooleanLike;
  world_time: number;
  ismartyr: BooleanLike;
};

type UplinkState = {
  allItems: UplinkItem[];
  allCategories: string[];
  currentTab: number;
};

type ServerData = {
  items: UplinkItem[];
  categories: string[];
};

type ItemExtraData = Item & {
  extraData: {
    ref?: string;
    icon: string;
    icon_state: string;
  };
};

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;

export class Uplink extends Component<{}, UplinkState> {
  constructor(props) {
    super(props);
    this.state = {
      allItems: [],
      allCategories: [],
      currentTab: 0,
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset('uplink.json')).then(
        (response) => response.json(),
      );
    }
    const { data } = useBackend<UplinkData>();

    const uplinkFlag = data.uplink_flag;
    const uplinkRole = data.assigned_role;
    const uplinkSpecies = data.assigned_species;

    const uplinkData = await fetchServerData;
    uplinkData.items = uplinkData.items.sort((a, b) => {
      if (a.cost < b.cost) {
        return -1;
      }
      if (a.cost > b.cost) {
        return 1;
      }
      return 0;
    });

    const availableCategories: string[] = [];
    uplinkData.items = uplinkData.items.filter((value) => {
      if (
        value.restricted_roles.length > 0 &&
        !value.restricted_roles.includes(uplinkRole) &&
        !data.debug
      ) {
        return false;
      }
      if (
        value.restricted_species.length > 0 &&
        !value.restricted_species.includes(uplinkSpecies) &&
        !data.debug
      ) {
        return false;
      }
      {
        if (value.purchasable_from & uplinkFlag) {
          return true;
        }
      }
      return false;
    });

    uplinkData.items.forEach((item) => {
      if (!availableCategories.includes(item.category)) {
        availableCategories.push(item.category);
      }
    });

    uplinkData.categories = uplinkData.categories.filter((value) =>
      availableCategories.includes(value),
    );

    this.setState({
      allItems: uplinkData.items,
      allCategories: uplinkData.categories,
    });
  }

  render() {
    const { data, act } = useBackend<UplinkData>();
    const {
      telecrystals,
      primary_objectives,
      can_renegotiate,
      extra_purchasable,
      extra_purchasable_stock,
      current_stock,
      lockable,
      purchased_items,
      shop_locked,
      world_time,
      ismartyr,
    } = data;
    const { allItems, allCategories, currentTab } = this.state as UplinkState;
    const itemsToAdd = [...allItems];
    const items: ItemExtraData[] = [];
    itemsToAdd.push(...extra_purchasable);
    for (let i = 0; i < extra_purchasable.length; i++) {
      const item = extra_purchasable[i];
      if (!allCategories.includes(item.category)) {
        allCategories.push(item.category);
      }
    }
    for (let i = 0; i < itemsToAdd.length; i++) {
      const item = itemsToAdd[i];
      const hasProgressionTimePassed = world_time >= item.progression_minimum;

      let stock: number | null = current_stock[item.stock_key];
      if (item.ref) {
        stock = extra_purchasable_stock[item.ref];
      }
      if (!stock && stock !== 0) {
        stock = null;
      }
      const canBuy = telecrystals >= item.cost && (stock === null || stock > 0);
      items.push({
        id: item.id,
        name: item.name,
        icon: item.icon,
        icon_state: item.icon_state,
        category: item.category,
        desc: (
          <>
            <Box>{item.desc}</Box>
            {(item.lock_other_purchases && (
              <NoticeBox mt={1}>
                Taking this item will lock you from further purchasing from the
                marketplace. Additionally, if you have already purchased an
                item, you will not be able to purchase this.
              </NoticeBox>
            )) ||
              null}
          </>
        ),
        cost: (
          <Box>
            {item.cost_override_string || `${item.cost} TC`}
            {!ismartyr && item.progression_minimum
              ? `, ${item.progression_minimum / 600} minutes`
              : ''}
          </Box>
        ),
        disabled:
          !canBuy ||
          (!ismartyr && !hasProgressionTimePassed) ||
          (item.lock_other_purchases && purchased_items > 0),
        extraData: {
          ref: item.ref,
          icon: item.icon,
          icon_state: item.icon_state,
        },
      });
    }
    return (
      <Window width={700} height={600} theme="syndicate">
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item>
              <Section fitted>
                <Stack fill>
                  <Stack.Item grow={1}>
                    <Tabs fluid>
                      <Tabs.Tab
                        style={{
                          overflow: 'hidden',
                          whiteSpace: 'nowrap',
                          textOverflow: 'ellipsis',
                        }}
                        icon="star"
                        selected={currentTab === 0}
                        onClick={() => this.setState({ currentTab: 0 })}
                      >
                        Objectives
                      </Tabs.Tab>
                      <Tabs.Tab
                        style={{
                          overflow: 'hidden',
                          whiteSpace: 'nowrap',
                          textOverflow: 'ellipsis',
                        }}
                        icon="store"
                        selected={currentTab === 1}
                        onClick={() => this.setState({ currentTab: 1 })}
                      >
                        Market
                      </Tabs.Tab>
                    </Tabs>
                  </Stack.Item>
                  <Stack.Item>
                    {(!ismartyr && (
                      <Box
                        lineHeight={2.5}
                        textAlign="center"
                        backgroundColor="transparent"
                        px={2}
                      >
                        <Icon name="clock" px={2} />
                        {(world_time / 600).toFixed(1)} Minutes
                      </Box>
                    )) || (
                      <Tooltip
                        content={
                          'You know what must be done, and you know youre not getting out. No time limits.'
                        }
                      >
                        <Box
                          lineHeight={2.5}
                          textAlign="center"
                          backgroundColor="transparent"
                          px={2}
                          bold
                        >
                          <Icon name="skull" px={1} />
                          MARTYR
                        </Box>
                      </Tooltip>
                    )}
                  </Stack.Item>
                  {!!lockable && (
                    <Stack.Item>
                      <Button
                        lineHeight={2.5}
                        textAlign="center"
                        icon="lock"
                        color="transparent"
                        px={2}
                        onClick={() => act('lock')}
                      >
                        Lock
                      </Button>
                    </Stack.Item>
                  )}
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              {(currentTab === 0 && (
                <PrimaryObjectiveMenu
                  primary_objectives={primary_objectives}
                  can_renegotiate={can_renegotiate}
                />
              )) || (
                <>
                  <GenericUplink
                    currency={`${telecrystals} TC`}
                    categories={allCategories}
                    items={items}
                    handleBuy={(item: ItemExtraData) => {
                      if (!item.extraData?.ref) {
                        act('buy', { path: item.id });
                      } else {
                        act('buy', { ref: item.extraData.ref });
                      }
                    }}
                  />
                  {(shop_locked && !data.debug && (
                    <Dimmer>
                      <Box
                        color="red"
                        fontFamily={'Bahnschrift'}
                        fontSize={3}
                        align={'top'}
                        as="span"
                      >
                        SHOP LOCKED
                      </Box>
                    </Dimmer>
                  )) ||
                    null}
                </>
              )}
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
}
