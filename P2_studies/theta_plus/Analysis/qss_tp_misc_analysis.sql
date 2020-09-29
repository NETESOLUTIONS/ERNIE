with cte as (
SELECT *
  FROM theta_plus.imm1985_1995_mcl_size_30_350_match_to_leiden mtl
JOIN theta_plus.imm1985_1995_all_merged_mcl amu
    ON amu.cluster_no=mtl.mcl_cluster_number
WHERE mtl.intersect_union_ratio >= 0.9)
select count(1) from cte;

with cte as (
SELECT *
  FROM theta_plus.imm2000_2004_mcl_size_30_350_match_to_leiden mtl
JOIN theta_plus.imm2000_2004_all_merged_mcl amu
    ON amu.cluster_no=mtl.mcl_cluster_number
WHERE mtl.intersect_union_ratio >= 0.9)
select count(1) from cte;

with cte as (
SELECT *
  FROM theta_plus_ecology.eco2000_2010_mcl_size_30_350_match_to_leiden mtl
JOIN theta_plus_ecology.eco2000_2010_all_merged_mcl amu
    ON amu.cluster_no=mtl.mcl_cluster_number
WHERE mtl.intersect_union_ratio >= 0.9) select count(1) from cte;

-- matching experts to MCL-Leiden convergence
with cte as (
SELECT *
  FROM theta_plus.imm1985_1995_mcl_size_30_350_match_to_leiden mtl
JOIN theta_plus.imm1985_1995_all_merged_mcl amu
    ON amu.cluster_no=mtl.mcl_cluster_number
join expert_ratings er ON er.imm1985_1995_cluster_no=amu.cluster_no
WHERE mtl.intersect_union_ratio >= 0.9)
select * from cte;