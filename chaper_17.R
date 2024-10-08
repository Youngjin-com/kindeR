pacman::p_load(tidyverse, tidymodels)
set.seed(1234)

tibble(
  �߰�_�¼� = rbinom(100000, 100, .5),
  ����_�·� = (�߰�_�¼� + 22) / 144,
  �����뼱 = sample(seq(.486, .559, .010), 100000, replace = TRUE),
  ����_���� = if_else(����_�·� >= �����뼱, 1, 0)
) -> lotte_simulation

lotte_simulation %>% 
  group_by(�߰�_�¼�) %>% 
  summarise(
    ��ü_Ƚ�� = n(),
    ����_���� = sum(����_����),
    ����_Ȯ�� =  ����_���� / ��ü_Ƚ��,
    .groups = 'drop'
  ) %>% 
  ggplot(aes(x = �߰�_�¼�, y = ����_Ȯ��)) +
  geom_line()

tibble(
  x = rbinom(100000, 100, .5),
  y = rbinom(100000, 100, .5),
  z = if_else(x > y, 1, 0)
) %>% 
  group_by(x) %>% 
  summarise(
    n = n(),
    z = sum(z),
    p = z / n,
    .groups = 'drop'
  ) %>% 
  ggplot(aes(x = x, y = p)) +
  geom_line() +
  geom_hline(yintercept = .5, linetype = 'dotted')

crossing(
  x = runif(100, 0, 1),
  y = runif(100, 0, 1)
) %>% 
  mutate(
    odds_x = x / (1 - x),
    odds_y = y / (1 - y),
    odds_ratio = odds_x / odds_y,
    logit = log(odds_ratio)
  ) %>% 
  ggplot(aes(x = logit)) +
  geom_histogram(bins = 30, fill = 'gray75', color = 'white')

tibble(
  x = seq(-10, 10, .1),
  y = exp(x) / (1 + exp(x))
) %>% 
  ggplot(aes(x = x, y = y)) +
  geom_line()

'kovo_set_by_set.csv' %>% 
  read.csv() %>% 
  as_tibble() -> kovo_sets

kovo_sets

kovo_sets %>%
  mutate(�¸� = �¸� %>% as_factor()) -> kovo_sets

kovo_sets %>% 
  filter(����� == '��') -> kovo_set_male

kovo_set_male %>%
  glm(�¸�  ~  ����ȿ�� + ���ú�ȿ�� + ����ȿ�� + ����ŷ + ���,
        family = binomial,
        data = .) %>% 
  tidy()

kovo_set_male %>%
  glm(�¸�  ~  ����ȿ�� + ���ú�ȿ�� + ����ȿ�� + ����ŷ + ���,
        family = binomial,
        data = .) %>% 
  vip::vi()

kovo_set_male %>%
  lm(����ȿ�� ~ ���ú�ȿ��, data = .) %>% 
  glance()

kovo_set_male %>% 
  initial_split(strata = '�¸�') -> set_split

set_split %>% training() -> set_train

set_split %>% testing() -> set_test

recipe(�¸� ~ ����ȿ�� + ���ú�ȿ�� + ����ȿ�� + ����ŷ + ���, data = set_train)

#�ּ� �ڵ�
grep("^step_", ls("package:recipes"), value = TRUE)

recipe(�¸� ~ ����ȿ�� + ���ú�ȿ�� + ����ȿ�� + ����ŷ + ���, data = set_train) %>% 
  step_corr(all_predictors()) %>%
  step_normalize(all_predictors(), -all_outcomes()) -> set_recipe

set_recipe %>% 
  prep()

set_recipe %>% 
  prep() %>% 
  juice()

logistic_reg() %>% 
  set_engine('glm') -> set_lr_model

set_lr_model

workflow() %>% 
  add_model(set_lr_model) %>% 
  add_recipe(set_recipe) -> set_lr_workflow

set_lr_workflow

set_lr_workflow %>% 
  fit(data = set_train) -> set_lr_fit

set_lr_fit

set_lr_fit %>% 
  tidy()

set_lr_fit %>% 
  predict(set_train)

set_lr_fit %>% 
  predict(set_train) %>% 
  bind_cols(set_train) %>% 
  relocate(�¸�, .before = ����)

set_lr_fit %>% 
  predict(set_train) %>% 
  bind_cols(set_train) %>% 
  metrics(truth = �¸�, estimate = .pred_class)

set_lr_fit %>% 
  predict(set_train) %>% 
  bind_cols(set_train) %>% 
  conf_mat(truth = �¸�, estimate = .pred_class) 

set_lr_fit %>% 
  predict(set_test) %>% 
  bind_cols(set_test) %>% 
  metrics(truth = �¸�, estimate = .pred_class)

set_lr_fit %>% 
  predict(set_train, type='prob') 

tibble(
  x = runif(100000, 0, 100),
  t = sample(seq(0, 100, 10), 100000, replace=TRUE),
  pred = if_else(x >= t, 1, 0),
  actual = sample(c(0, 1), 100000, replace=TRUE)
) %>% 
  group_by(t) %>% 
  summarise(
    true_true = sum(actual == 1 & pred == 1),
    true_false = sum(actual == 1 & pred == 0),
    false_true = sum(actual == 0 & pred == 1),
    false_false = sum(actual == 0 & pred == 0),
    sensitivity = true_true / (true_true + true_false),
    specificity = false_false / (false_true + false_false),
    .groups = 'drop'
  ) %>% 
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_path()

set_lr_fit %>% 
  predict(set_train, type='prob') %>% 
  bind_cols(set_train) %>% 
  roc_curve(truth = �¸�, estimate = .pred_0)

set_lr_fit %>% 
  predict(set_train, type='prob') %>% 
  bind_cols(set_train) %>% 
  roc_curve(truth = �¸�, estimate = .pred_0) %>% 
  autoplot()

set_lr_fit %>% 
  predict(set_test, type='prob') %>% 
  bind_cols(set_test) %>% 
  roc_curve(truth = �¸�, estimate = .pred_0) %>% 
  ggplot(aes(x = 1 - specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(linetype = 'dotted') +
  coord_equal()

set_lr_fit %>% 
  predict(set_train, type='prob') %>% 
  bind_cols(set_train) %>% 
  roc_auc(truth = �¸�, .pred_0) 

set_lr_fit %>% 
  predict(set_test, type='prob') %>% 
  bind_cols(set_test) %>% 
  roc_auc(truth = �¸�, .pred_0)