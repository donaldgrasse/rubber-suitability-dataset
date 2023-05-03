---
Rubber Suitability Dataset
---

**About** 
Code to produce a rubber suitability raster dataset at a 1x1 kilometer resolution in Southern Thailand

**Background of Algorithm** 
For any particular geographic feature $x$, there is a range of the potential values where (1) growth of the crop is optimal (x max optimal, x min optimal) and more generally (2) growth of the crop is possibile (x max possible, x max minimal). We use these parameters to construct a normalized score for each location $i$.

We want to know the level of crop suitability (S) for grid cell $i$. We have data on $n$ features indexed by $k \in \\{1, 2, ..., n\\}$. We define suitability as the product of all the suitability features.   

$$S_i = \prod_{k=1}^{n} x_{i}^{k}$$ 
