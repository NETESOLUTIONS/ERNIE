-- region ct_arm_groups
ALTER TABLE ct_arm_groups
  ALTER COLUMN arm_group_label SET NOT NULL;
--

CREATE UNIQUE INDEX ct_arm_groups_uk
  ON ct_arm_groups (nct_id, arm_group_label, arm_group_type, description)
TABLESPACE ernie_index_tbs;
-- 6.8s
-- endregion