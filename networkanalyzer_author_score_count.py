

data = pd.read_csv('/Users/djamillakhdar-hamina/Desktop/kavli_mdressel_combined_4col.csv')
# Count edges to target
edge_count=data.groupby('target').count()
# Merge back to x using target-> target
target_self_merge= pd.merge(data, edge_count,  left_on='target', right_on='target')
# Merge back to x using source -> target. Use outer join this time.
source_self_merge= pd.merge(target_self_merge, edge_count,  left_on='source_x', right_on='target', how='left')
# Replace NA with 0
source_self_merge=source_self_merge.fillna(0)
# type casts
source_self_merge[['source','source_y']]=source_self_merge[['source','source_y']].astype('float')
source_self_merge[['target']]=source_self_merge[['target']].astype('category')
## calculate author_score
##author_score=source_self_merge.groupby('target',as_index=False).agg({'source':'sum','source_y':'sum'})
author_score=article_score.groupby('target').sum(axis=0)
author_score['score']=article_score['source']+article_score['source_y']
author_score.sort_values(by='score')
