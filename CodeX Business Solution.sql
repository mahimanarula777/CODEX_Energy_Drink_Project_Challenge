
---------------------------CODEX :Energy Drink: Case Study CodeBaiscs Challenge --------------------------------
Use Marketing_Project

---------------------------------------------- 1. Demographic Insights -----------------------------------------

--1.a. Who prefers energy drink more? (male/female/non-binary?)

select Gender, count(*) as Gender_count,
				(count(*) * 100/ (Select count(*) from fact_survey_responses)) as [Percentage]
from fact_survey_responses as A
left join
dim_repondents as B
on A.Respondent_ID = B.Respondent_ID
group by Gender
order by Gender_count desc


--1.b Which age group prefers energy drinks more?

select Age, count(*) as Age_Group_Count,
				cast((count(*) * 100/ (Select count(*) from fact_survey_responses)) as varchar) + '%' as [Percentage]
from fact_survey_responses as A
left join
dim_repondents as B
on A.Respondent_ID = B.Respondent_ID
group by Age
order by Age_Group_Count desc

--1.c. Which type of marketing reaches the most Youth (15-30)?

select Marketing_channels, count(*) as [Total_response (15-30)], 
count(*)*100 / (
		select count(*) from fact_survey_responses A
		left join dim_repondents B
		on A.Respondent_ID=B.Respondent_ID
		where Age in('19-30','15-18')
		) as [%Value]
from fact_survey_responses  A
left join dim_repondents B
on A.Respondent_ID=B.Respondent_ID
group by Marketing_channels
order by [Total_response (15-30)]

---------------------------------------------- 2. Consumer Preferences -----------------------------------------

--2.a. What are the preferred ingredients of energy drinks among respondents?


select Ingredients_expected, count(*) as Prefered_Ingredents_Count,
cast (count(*) *100 / (select count(*) from fact_survey_responses) as varchar) + '%' as [Percentage]
from fact_survey_responses
group by Ingredients_expected
order by Prefered_Ingredents_Count desc

--2.b. What packaging preferences do respondents have for energy drinks?

select Packaging_preference, count(*) as Prefered_Packaging_Count ,
cast(count(*) *100/ (select count(*) from fact_survey_responses) as varchar) + '%' as [Percentage]
from fact_survey_responses
group by Packaging_preference
order by Prefered_Packaging_Count desc

---------------------------------------------- 3. Competition Analysis -----------------------------------------

--3.a. Who are the current market leaders?

select Current_brands, count(*) as No_of_brand,
	cast(count(*) *100/ (select count(*) from fact_survey_responses) as varchar) + '%' as [Percentage]
from fact_survey_responses
group by Current_brands
order by  count(*) desc

--3.b. What are the primary reasons consumers prefer those brands over ours?

select Reasons_for_choosing_brands, count(*) as Reason_count,
		cast(count(*) *100/ (select count(*) from fact_survey_responses) as varchar) + '%' as [Percentage]
from fact_survey_responses
group by Reasons_for_choosing_brands
order by Reason_count desc

---------------------------------------------- 4. Marketing Channels and Brand Awareness -----------------------------------------

--4.a. Which marketing channel can be used to reach more customers?

select Marketing_channels, count(*) as channel_count, 
	cast(count(*) *100/ (select count(*) from fact_survey_responses) as varchar) + '%' as [Percentage]
from fact_survey_responses
group by Marketing_channels
order by channel_count desc

--4.b. How effective are different marketing strategies and channels in reaching our customers?

---- Merketing channels by target age groups

with channel_by_age  
as (
	select * from (
		select Marketing_channels, Age, count(*) as Total
		from fact_survey_responses as A
		left join dim_repondents as B
		on A.Respondent_ID = B.Respondent_ID
		group by Marketing_channels, Age
	) as X
	pivot(sum(Total) for age in ([15-18], [19-30],[31-45])
	) as pivot_table
)
select *, ([15-18]+[19-30]+[31-45]) as total from channel_by_age
order by total desc

---------------------------------------------- 5. Brand Penetration -----------------------------------------

--5.a. What do people think about our brand? (overall rating)

select City,
sum (Case when Brand_perception in ('Neutral', 'Positive') then 1 else 0 End) as [Neautral and positive response],
sum (Case when Brand_perception = 'Negative' then 1 else 0 End) as [Negative response]
from fact_survey_responses as A
inner join dim_repondents as B
on A.Respondent_ID = B.Respondent_ID
inner join dim_cities as C
on B.City_ID = C.City_ID
where Current_brands = 'CodeX'
group by City
order by count(*) desc

-- Overall Rating

with cte 
as (select *, (Case 
					when Brand_perception = 'Neutral' then 2
					when Brand_perception = 'Positive' then 3
					else 1
				End) as Brand_rating_count
	from fact_survey_responses
)
select avg(Brand_rating_count) as brand_rating from cte

--5.b. Which cities do we need to focus more on?

-- finding the city wise brand heard response

select C.City, 
		sum(case 
			when Heard_before = '1' then 1 else 0
		End) as Heard_before,
		sum(case
			when heard_before = '0' then 1 else 0
		End) as Heard_not_before,
		count(*) as total_responses
from fact_survey_responses as A
inner join dim_repondents as B
on A.Respondent_ID = B.Respondent_ID
inner join dim_cities as C
on B.City_ID = C.City_ID
group by C.City

-- finding the city wise CodeX response 

select city, count(*) as CodeX_response
from fact_survey_responses as A
inner join dim_repondents as B
on A.Respondent_ID = B.Respondent_ID
inner join dim_cities as C
on B.City_ID = C.City_ID
where Current_brands = 'CodeX'
group by city

--Using both above queries for final output:

With Heard_before_responses as (
	select C.City, 
			sum(case when Heard_before = '1' then 1 else 0 End) as Heard_before,
			sum(case when heard_before = '0' then 1 else 0 End) as Heard_not_before,
			count(*) as total_responses
	from fact_survey_responses as A
	inner join dim_repondents as B
	on A.Respondent_ID = B.Respondent_ID
	inner join dim_cities as C
	on B.City_ID = C.City_ID
	group by C.City
),
CodeX_Response as (
	select city, count(*) as CodeX_response
	from fact_survey_responses as A
	inner join dim_repondents as B
	on A.Respondent_ID = B.Respondent_ID
	inner join dim_cities as C
	on B.City_ID = C.City_ID
	where Current_brands = 'CodeX'
	group by city
)
select X.*, CodeX_response from Heard_before_responses as X
join CodeX_Response as Y
on X.City = Y.City
order by CodeX_response desc

---------------------------------------------- 6. Purchase Behavior -----------------------------------------

--6.a. Where do respondents prefer to purchase energy drinks?

--- city wise preference
select City
from dim_repondents as A
left join dim_cities as B
on A.City_ID = B.City_ID
group by City
order by count(Respondent_ID) desc

-- Puchase location wise preference
select Purchase_location, count(*) as Location_count
from fact_survey_responses
group by Purchase_location
order by Location_count desc


-----Using both above queries for final output:

select City, [Gyms and Fitness Centers], [Local Stores], [Online Retailers], [Other], [Supermarkets], 
[Gyms and Fitness Centers]+[Local Stores] + [Online Retailers] + [Other]+[Supermarkets] as Total_Purchase_Location
from 
(
	select * from (
		select City, Purchase_location, count(*) as Total_Count from fact_survey_responses as A
		inner join dim_repondents as B
		on A.Respondent_ID = B.Respondent_ID
		join dim_cities as C
		on B.City_ID = C.City_ID
		group by City, Purchase_location
	) as X
	pivot(sum(Total_Count) for Purchase_location 
	in ([Gyms and Fitness Centers], [Local Stores], [Online Retailers], [Other], [Supermarkets])
	) as pivot_table
) as Y
order by Total_Purchase_Location desc

--6.b. What are the typical consumption situations for energy drinks among respondents?

select Typical_consumption_situations, count(*) as Consumption_situation_count 
from fact_survey_responses
group by Typical_consumption_situations
order by consumption_situation_count desc

--6.c. What factors influence respondents' purchase decisions, such as price range and limited edition packaging?

-- Influcing factor: count of Price range
select Price_range, count(*) as count_ from fact_survey_responses
group by Price_range

--Influcing factor: count of Health concerns
select Health_concerns, count(*) as count_
from fact_survey_responses
group by Health_concerns

--Influcing factor: count of Price_rangeLimited Edition Packaging
select 
(case when Limited_edition_packaging = 1 then 'Yes' 
	 when Limited_edition_packaging = 0 then 'No'
	 else 'Not Sure'
End) as Limited_edition, count(*) as edition_packaging_count
from fact_survey_responses
group by Limited_edition_packaging
order by edition_packaging_count desc

---------------------------------------------- 7. Product Development -----------------------------------------

--7.a. Which area of business should we focus more on our product development?
--(Branding/taste/availability)

-- Areas to look for
select Reasons_preventing_trying, count(*) as count_reason_preventing from fact_survey_responses
where Current_brands = 'CodeX'
group by Reasons_preventing_trying

--- Need Branding wise improvement
select Reasons_for_choosing_brands, 
cast(count(*)*100/ (select count(*) from fact_survey_responses) as varchar) + '%' as [%_Distribution] 
from fact_survey_responses
group by Reasons_for_choosing_brands
order by [%_Distribution] desc

-- --Taste_experience across Age Groups
select Taste_experience, [15-18], [19-30], [31-45], [65+], [15-18] + [19-30]+ [31-45] + [65+] as [Total], 
cast (([15-18] + [19-30]+ [31-45] + [65+]) * 100/  (select count(*) from fact_survey_responses) as varchar) + '%' as [Percentage]
from 
(
select * from (
		select Taste_experience,Age, count(*) as total
		FROM fact_survey_responses as A
		JOIN dbo.dim_repondents as B ON A.Respondent_ID = B.Respondent_ID
		group by Taste_experience,Age) as X
pivot (sum(total) for Age
in ([15-18], [19-30], [31-45], [65+])
) as pivot_table
) as Y
order by [Total] desc

--  Improvement Areas
select Improvements_desired, count(*) as Needed_Improvement_count,
cast(count(*)*100/ (select count(*) from fact_survey_responses) as varchar) + '%' as [%_Distribution] 
from fact_survey_responses
group by Improvements_desired
order by Needed_Improvement_count desc


