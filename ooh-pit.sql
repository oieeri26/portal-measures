/* 
Out-of-Home - Point in Time Count
Include:
	- Race/Eth -- need to add
	- Gender
	- Initial Placement
*/
WITH prm_plcm_setng
AS (
	SELECT DISTINCT 0 AS cd_plcm_setng
		,cd_plcm_setng AS match_code
	FROM [CA_ODS].[base].[rptPlacement_Events]
	
	UNION
	
	SELECT DISTINCT cd_plcm_setng AS cd_plcm_setng
		,cd_plcm_setng AS match_code
	FROM [CA_ODS].[base].[rptPlacement_Events]
	)
	,prm_gndr
AS (
	SELECT pm.pk_gndr
		,g.cd_gndr
	FROM [CA_ODS].[dbo].[prm_gndr] AS pm
	LEFT JOIN [CA_ODS].[dbo].[ref_lookup_gender] AS g ON pm.match_code = g.pk_gndr
	)
SELECT cd.CALENDAR_DATE AS [date]
	,g.pk_gndr
	,ps.cd_plcm_setng
	,COUNT(*) AS cnt
FROM [CA_ODS].[base].[rptPlacement] AS p
LEFT JOIN [CA_ODS].[dbo].[CALENDAR_DIM] AS cd ON cd.CALENDAR_DATE BETWEEN p.removal_dt
		AND discharge_dt
LEFT JOIN [CA_ODS].[base].[rptPlacement_Events] AS ip ON p.id_removal_episode_fact = ip.id_removal_episode_fact AND ip.plcmnt_seq = 1
JOIN prm_gndr AS g ON p.cd_gndr = g.cd_gndr
JOIN prm_plcm_setng AS ps ON ps.match_code = ip.cd_plcm_setng
WHERE YEAR(cd.[YEAR]) >= 2000
	AND cd.CALENDAR_DATE < GETDATE()
	AND cd.CALENDAR_DATE = cd.[QUARTER]
GROUP BY cd.CALENDAR_DATE
	,g.pk_gndr
	,ps.cd_plcm_setng
ORDER BY cd.CALENDAR_DATE
	,g.pk_gndr
	,ps.cd_plcm_setng
