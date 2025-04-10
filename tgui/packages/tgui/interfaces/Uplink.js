import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';

import { createSearch, decodeHtmlEntities } from 'common/string';
import { Countdown } from '../components/Countdown';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Input,
  Section,
  Stack,
  Divider,
  Tabs,
  LabeledList,
  Icon,
} from '../components';
import { Window } from '../layouts';
import {
  ComplexModal,
  modalOpen,
  modalAnswer,
  modalRegisterBodyOverride,
} from './common/ComplexModal';

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <ItemsPage />;
    case 1:
      return <CartPage />;
    case 2:
      return <ExploitableInfoPage />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

export const Uplink = (props) => {
  const { act, data } = useBackend();
  const { cart } = data;

  const [tabIndex, setTabIndex] = useLocalState('tabIndex', 0);
  const [searchText, setSearchText] = useLocalState('searchText', '');

  return (
    <Window width={900} height={700} theme="syndicate">
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="PurchasePage"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                  setSearchText('');
                }}
                icon="store"
              >
                Магазин
              </Tabs.Tab>
              <Tabs.Tab
                key="Cart"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                  setSearchText('');
                }}
                icon="shopping-cart"
              >
                Корзина {cart && cart.length ? '(' + cart.length + ')' : ''}
              </Tabs.Tab>
              <Tabs.Tab
                key="ExploitableInfo"
                selected={tabIndex === 2}
                onClick={() => {
                  setTabIndex(2);
                  setSearchText('');
                }}
                icon="user"
              >
                Информация
              </Tabs.Tab>
              {!!data.contractor && (
                <Tabs.Tab
                  key="BecomeContractor"
                  color={
                    !!data.contractor.available && !data.contractor.accepted
                      ? 'yellow'
                      : 'transparent'
                  }
                  onClick={() => modalOpen('become_contractor')}
                  icon="suitcase"
                >
                  Заключение контракта
                  {!data.contractor.is_admin_forced &&
                  !data.contractor.accepted ? (
                    data.contractor.available_offers > 0 ? (
                      <i>[Осталось:{data.contractor.available_offers}]</i>
                    ) : (
                      <i>[Предложения закончились]</i>
                    )
                  ) : (
                    ''
                  )}
                  {data.contractor.accepted ? (
                    <i>&nbsp;(Заключён)</i>
                  ) : !data.contractor.is_admin_forced &&
                    data.contractor.available_offers <= 0 ? (
                    ''
                  ) : (
                    <Countdown
                      timeLeft={data.contractor.time_left}
                      format={(v, f) => ' (' + f + ')'}
                      bold
                    />
                  )}
                </Tabs.Tab>
              )}
              <Tabs.Tab
                key="LockUplink"
                // This cant ever be selected. Its just a close button.
                onClick={() => act('lock')}
                icon="lock"
              >
                Заблокировать
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{PickTab(tabIndex)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemsPage = (_properties) => {
  const { act, data } = useBackend();
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useLocalState(
    'uplinkItems',
    cats[0].items
  );

  const [searchText, setSearchText] = useLocalState('searchText', '');
  const SelectEquipment = (cat, searchText = '') => {
    const EquipmentSearch = createSearch(searchText, (item) => {
      let is_hijack = item.hijack_only === 1 ? '|' + 'hijack' : '';
      return item.name + '|' + item.desc + '|' + item.cost + 'tc' + is_hijack;
    });
    return flow([
      filter((item) => item?.name), // Make sure it has a name
      searchText && filter(EquipmentSearch), // Search for anything
      sortBy((item) => item?.name), // Sort by name
    ])(cat);
  };
  const handleSearch = (value) => {
    setSearchText(value);
    if (value === '') {
      return setUplinkItems(cats[0].items);
    }
    setUplinkItems(
      SelectEquipment(cats.map((category) => category.items).flat(), value)
    );
  };

  const [showDesc, setShowDesc] = useLocalState('showDesc', 1);

  return (
    <Stack fill vertical>
      <Stack vertical>
        <Stack.Item>
          <Section
            title={'Текущий баланс: ' + crystals + ' ' + 'ТК'}
            buttons={
              <>
                <Button.Checkbox
                  content="Показывать описание"
                  checked={showDesc}
                  onClick={() => setShowDesc(!showDesc)}
                />
                <Button
                  content="Случайный предмет"
                  icon="question"
                  onClick={() => act('buyRandom')}
                />
                <Button
                  content="Сделать возврат"
                  icon="undo"
                  onClick={() => act('refund')}
                />
              </>
            }
          >
            <Input
              fluid
              placeholder="Поиск..."
              onInput={(e, value) => {
                handleSearch(value);
              }}
              value={searchText}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="26%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c) => (
                <Tabs.Tab
                  key={c}
                  selected={searchText !== '' ? false : c.items === uplinkItems}
                  onClick={() => {
                    setUplinkItems(c.items);
                    setSearchText('');
                  }}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                  mb={0.5}
                  ml={0.5}
                >
                  {c.cat}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            <Stack vertical>
              {uplinkItems.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    key={decodeHtmlEntities(i.name)}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};

const CartPage = (_properties) => {
  const { act, data } = useBackend();
  const { cart, crystals, cart_price } = data;

  const [showDesc, setShowDesc] = useLocalState('showDesc', 0);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Текущий баланс: ' + crystals + ' ' + 'ТК'}
          buttons={
            <>
              <Button.Checkbox
                content="Показывать описание"
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              />
              <Button
                content="Очистить корзину"
                icon="trash"
                onClick={() => act('empty_cart')}
                disabled={!cart}
              />
              <Button
                content={'Купить корзину (' + cart_price + 'TC)'}
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > crystals}
              />
            </>
          }
        >
          <Stack vertical>
            {cart ? (
              cart.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  mr={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    buttons={<CartButtons i={i} />}
                  />
                </Stack.Item>
              ))
            ) : (
              <Box italic>Ваша корзина пуста!</Box>
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Advert />
    </Stack>
  );
};
const Advert = (_properties) => {
  const { act, data } = useBackend();
  const { cats, lucky_numbers } = data;
  const [showDesc, setShowDesc] = useLocalState('showDesc', 0);

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Рекомендуемые товары"
        buttons={
          <Button
            icon="dice"
            content="Новые рекомендации"
            onClick={() => act('shuffle_lucky_numbers')}
          />
        }
      >
        <Stack wrap>
          {lucky_numbers
            .map((number) => cats[number.cat].items[number.item])
            .filter((item) => item !== undefined && item !== null)
            .map((item, index) => (
              <Stack.Item
                key={index}
                p={1}
                mb={1}
                ml={1}
                width={34}
                backgroundColor={'rgba(255, 0, 0, 0.15)'}
              >
                <UplinkItem grow i={item} showDecription={showDesc} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const UplinkItem = (props) => {
  const {
    i,
    showDecription = 1,
    buttons = <UplinkItemButtons i={i} />,
  } = props;

  return (
    <Section title={decodeHtmlEntities(i.name)} showBottom={showDecription}>
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
      <Box mt={2}>{buttons}</Box>
    </Section>
  );
};

const UplinkItemButtons = (props) => {
  const { act, data } = useBackend();
  const { i } = props;
  const { crystals } = data;

  return (
    <>
      <Button
        icon="shopping-cart"
        color={i.hijack_only === 1 && 'red'}
        tooltip="Добавить в корзину"
        tooltipPosition="left"
        onClick={() =>
          act('add_to_cart', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
      <Button
        content={
          'Купить (' +
          i.cost +
          ' ' +
          'ТК)' +
          (i.refundable ? ' [Возвращаемый]' : '')
        }
        color={i.hijack_only === 1 && 'red'}
        // Yes I care this much about both of these being able to render at the same time
        tooltip={
          i.hijack_only === 1 &&
          'Только для агентов, имеющих цель — угон эвакуационного шаттла!'
        }
        tooltipPosition="left"
        onClick={() =>
          act('buyItem', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
    </>
  );
};

const CartButtons = (props) => {
  const { act, data } = useBackend();
  const { i } = props;
  const { exploitable } = data;

  return (
    <Stack>
      <Button
        icon="times"
        content={'(' + i.cost * i.amount + ' ' + 'ТК)'}
        tooltip="Удалить из корзины"
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      />
      <Button
        icon="minus"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        ml="5px"
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: --i.amount, // one lower
          })
        }
        disabled={i.amount <= 0}
      />
      <Button.Input
        content={i.amount}
        width="45px"
        tooltipPosition="bottom-end"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        onCommit={(e, value) =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: value,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit && i.amount <= 0}
      />
      <Button
        mb={0.3}
        icon="plus"
        tooltipPosition="bottom-start"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: ++i.amount, // one higher
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit}
      />
    </Stack>
  );
};

const ExploitableInfoPage = (_properties) => {
  const { act, data } = useBackend();
  const { exploitable } = data;
  // Default to first
  const [selectedRecord, setSelectedRecord] = useLocalState(
    'selectedRecord',
    exploitable[0]
  );

  const [searchText, setSearchText] = useLocalState('searchText', '');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    const MemberSearch = createSearch(searchText, (member) => member.name);
    return flow([
      // Null member filter
      filter((member) => member?.name),
      // Optional search term
      searchText && filter(MemberSearch),
      // Slightly expensive, but way better than sorting in BYOND
      sortBy((member) => member.name),
    ])(people);
  };

  const crew = SelectMembers(exploitable, searchText);

  return (
    <Section fill title="Записи об экипаже">
      <Stack fill>
        <Stack.Item width="30%" fill>
          <Section fill scrollable>
            <Input
              fluid
              mb={1}
              placeholder="Поиск..."
              onInput={(e, value) => setSearchText(value)}
            />
            <Tabs vertical>
              {crew.map((r) => (
                <Tabs.Tab
                  key={r}
                  selected={r === selectedRecord}
                  onClick={() => setSelectedRecord(r)}
                >
                  {r.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item grow>
          <Section fill title={selectedRecord.name} scrollable>
            <LabeledList>
              <LabeledList.Item label="Возраст">
                {selectedRecord.age}
              </LabeledList.Item>
              <LabeledList.Item label="Отпечаток пальцев">
                {selectedRecord.fingerprint}
              </LabeledList.Item>
              <LabeledList.Item label="Должность">
                {selectedRecord.rank}
              </LabeledList.Item>
              <LabeledList.Item label="Пол">
                {selectedRecord.sex}
              </LabeledList.Item>
              <LabeledList.Item label="Раса">
                {selectedRecord.species}
              </LabeledList.Item>
              <LabeledList.Item label="Записи">
                {selectedRecord.exploit_record}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

modalRegisterBodyOverride('become_contractor', (modal) => {
  const { data } = useBackend();
  const { time_left } = data.contractor || {};
  const isAvailable = !!data?.contractor?.available;
  const isAffordable = !!data?.contractor?.affordable;
  const isAccepted = !!data?.contractor?.accepted;
  const { available_offers } = data.contractor || {};
  const isAdminForced = !!data?.contractor?.is_admin_forced;
  return (
    <Section
      height="65%"
      level="2"
      m="-1rem"
      pb="1rem"
      title={
        <>
          <Icon name="suitcase" />
          &nbsp; Заключение контракта
        </>
      }
    >
      <Box mx="0.8rem" mb="1rem">
        <b>
          Ваши достижения в службе Синдикату были отмечены, агент! Мы рады
          предложить вам уникальную возможность стать контрактником.
        </b>
        <br />
        <br />
        Мы предлагаем вам повышение до уровня контрактника всего за 100
        телекристаллов. Это позволит вам заключать контракты на похищение людей,
        получая за свою работу телекристаллы и кредиты.
        <br />
        Кроме того, вам будет выдан стандартный набор контрактника, специальный
        аплинк контрактника, руководство и три случайных недорогих предмета.
        <br />
        <br />
        Более подробные инструкции вы сможете найти в руководстве, которое
        прилагается к комплекту, если решите воспользоваться нашим предложением.
        {!isAdminForced ? (
          <Box>
            Не упустите возможность! Вы не единственный, кто получил это
            предложение. Количество доступных предложений ограничено, и если
            другие агенты примут их раньше вас, то у вас не останется
            возможности принять участие.
            <br />
            <b>Доступные предложения: {available_offers}</b>
          </Box>
        ) : (
          ''
        )}
      </Box>
      <Button.Confirm
        disabled={!isAvailable || isAccepted}
        italic={!isAvailable}
        bold={isAvailable}
        icon={isAvailable && !isAccepted && 'check'}
        color="good"
        content={
          isAccepted ? (
            'Заключён'
          ) : isAvailable ? (
            [
              'Принять предложение',
              <Countdown
                key="countdown"
                timeLeft={time_left}
                format={(v, f) => ' (' + f + ')'}
              />,
            ]
          ) : !isAffordable ? (
            'Недостаточно ТК'
          ) : !data.contractor.is_admin_forced ? (
            data.contractor.available_offers > 0 ? (
              <i>[Осталось:{data.contractor.available_offers}]</i>
            ) : (
              <i>[Предложения закончились]</i>
            )
          ) : (
            'Срок действия предложения истек'
          )
        }
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => modalAnswer(modal.id, 1)}
      />
    </Section>
  );
});
