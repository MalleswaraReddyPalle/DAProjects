/*This file contains all the solutions for the problems in Problems_1.PNG and Problems_2.PNG*/
use IndianElectionResults;

select * from constituencywise_details;
select * from constituencywise_results;
select * from partywise_results;
select * from statewise_results where State_ID='U05';
select * from states;
--1. Total seats

select count(*) as total_seats from constituencywise_details group by Constituency_ID;--no. of candidates participated per constituency

select count(*) as total_seats from constituencywise_results; -- Total seats in India

-- What are the total no. of seats available for elections in each state

select sr.State_ID,s.state as state_name, count(*) as state_wise_seats from statewise_results sr inner join states s on sr.State_ID=s.State_ID group by sr.State_ID,s.State;

-- Total seats won by NDA alliance

SELECT 
    SUM(CASE 
            WHEN party IN (
                'Bharatiya Janata Party - BJP', 
                'Telugu Desam - TDP', 
				'Janata Dal  (United) - JD(U)',
                'Shiv Sena - SHS', 
                'AJSU Party - AJSUP', 
                'Apna Dal (Soneylal) - ADAL', 
                'Asom Gana Parishad - AGP',
                'Hindustani Awam Morcha (Secular) - HAMS', 
                'Janasena Party - JnP', 
				'Janata Dal  (Secular) - JD(S)',
                'Lok Janshakti Party(Ram Vilas) - LJPRV', 
                'Nationalist Congress Party - NCP',
                'Rashtriya Lok Dal - RLD', 
                'Sikkim Krantikari Morcha - SKM'
            ) THEN [Won]
            ELSE 0 
        END) AS NDA_Total_Seats_Won
FROM 
    partywise_results;

--Add new column field in table partywise_results to get the Party Allianz as NDA, I.N.D.I.A and OTHER
ALTER TABLE partywise_results
ADD party_alliance VARCHAR(50);

--I.N.D.I.A
UPDATE partywise_results
SET party_alliance = 'I.N.D.I.A'
WHERE party IN (
    'Indian National Congress - INC',
    'Aam Aadmi Party - AAAP',
    'All India Trinamool Congress - AITC',
    'Bharat Adivasi Party - BHRTADVSIP',
    'Communist Party of India  (Marxist) - CPI(M)',
    'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
    'Communist Party of India - CPI',
    'Dravida Munnetra Kazhagam - DMK',	
    'Indian Union Muslim League - IUML',
    'Jammu & Kashmir National Conference - JKN',
    'Jharkhand Mukti Morcha - JMM',
    'Kerala Congress - KEC',
    'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
    'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
    'Rashtriya Janata Dal - RJD',
    'Rashtriya Loktantrik Party - RLTP',
    'Revolutionary Socialist Party - RSP',
    'Samajwadi Party - SP',
    'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
    'Viduthalai Chiruthaigal Katchi - VCK'
);

--NDA
UPDATE partywise_results
SET party_alliance = 'NDA'
WHERE party IN (
    'Bharatiya Janata Party - BJP',
    'Telugu Desam - TDP',
    'Janata Dal  (United) - JD(U)',
    'Shiv Sena - SHS',
    'AJSU Party - AJSUP',
    'Apna Dal (Soneylal) - ADAL',
    'Asom Gana Parishad - AGP',
    'Hindustani Awam Morcha (Secular) - HAMS',
    'Janasena Party - JnP',
    'Janata Dal  (Secular) - JD(S)',
    'Lok Janshakti Party(Ram Vilas) - LJPRV',
    'Nationalist Congress Party - NCP',
    'Rashtriya Lok Dal - RLD',
    'Sikkim Krantikari Morcha - SKM'
);

--OTHER
UPDATE partywise_results
SET party_alliance = 'OTHER'
WHERE party_alliance IS NULL;

-- Total seats won by NDA alliance

select sum(Won) as NDA_total_seats_won from partywise_results where party_alliance='NDA';

--Total seats won by NDA alliance parties

select party,won as NDA_alliance_parties_seats from partywise_results where party_alliance='NDA';

--Total seats won by I.N.D.I.A alliance

select sum(Won) as INDIA_total_seats_won from partywise_results where party_alliance='I.N.D.I.A';

--Total seats won by I.N.D.I.A alliance parties

select party,won as INDIA_alliance_parties_seats from partywise_results where party_alliance='I.N.D.I.A';

-- which party alliance won most seats
select party_alliance,sum(won) as seats_won from partywise_results group by party_alliance;

--winning candidate name, party name,total votes,and margin of victory for specific state and constituency

select cr.Winning_Candidate,cr.Constituency_Name,sr.State,pr.Party,cr.Total_Votes,cr.Margin from constituencywise_results cr 
inner join partywise_results pr on cr.Party_ID=pr.Party_ID inner join statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
order by sr.state,cr.Margin desc;

--what is the distribution of EVM votes vs postalvotes for cadidate for each constituency
select cd.Candidate,cd.EVM_Votes,cd.Postal_Votes,cd.Total_Votes,cr.Constituency_name from constituencywise_results cr 
inner join constituencywise_details cd on cd.Constituency_ID=cr.Constituency_ID
where Constituency_Name='NANDYAL';

--most NOTA votes

select cd.Candidate,cd.EVM_Votes,cd.Postal_Votes,cd.Total_Votes,cd.Party,cr.Constituency_Name from constituencywise_details cd 
inner join constituencywise_results cr on cd.Constituency_ID=cr.Constituency_ID
inner join statewise_results sr on cr.Parliament_Constituency=sr.Parliament_Constituency
where Candidate='NOTA' and sr.State='Andhra Pradesh' order by EVM_Votes DESC;

--which parties won most seats in each state and how many seats did each party won
select s.State,pr.Party,count(cr.Winning_Candidate) as seats_won from constituencywise_results cr 
inner join statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
inner join partywise_results pr on pr.Party_ID=cr.Party_ID 
inner join states s on sr.State_ID=s.State_ID
where s.State='Delhi'
group by s.State,pr.Party order by s.State;

--What is the total no of seats won by each party alliance in each state
select pr.party_alliance,s.State,count(cr.Winning_Candidate) as seats_won from partywise_results pr 
left join constituencywise_results cr on cr.Party_ID=pr.Party_ID
left join statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
left join states s on s.State_ID=sr.State_ID
group by pr.party_alliance,s.State
order by pr.party_alliance,s.State;

SELECT 
    s.State AS State_Name,
    SUM(CASE WHEN p.party_alliance = 'NDA' THEN 1 ELSE 0 END) AS NDA_Seats_Won,
    SUM(CASE WHEN p.party_alliance = 'I.N.D.I.A' THEN 1 ELSE 0 END) AS INDIA_Seats_Won,
	SUM(CASE WHEN p.party_alliance = 'OTHER' THEN 1 ELSE 0 END) AS OTHER_Seats_Won
FROM 
    constituencywise_results cr
JOIN 
    partywise_results p ON cr.Party_ID = p.Party_ID
JOIN 
    statewise_results sr ON cr.Parliament_Constituency = sr.Parliament_Constituency
JOIN 
    states s ON sr.State_ID = s.State_ID
--WHERE 
  --  p.party_alliance IN ('NDA', 'I.N.D.I.A',  'OTHER')  -- Filter for NDA and INDIA alliances
GROUP BY 
    s.State
ORDER BY 
    s.State;


--Which candidate received highest no. of EVM votes in each constituency
select cr.Constituency_Name,cd.Candidate,cd.EVM_Votes from constituencywise_details cd
join constituencywise_results cr on cr.Constituency_ID=cd.Constituency_ID
where cd.EVM_Votes in (select max(EVM_Votes) from constituencywise_details cd1 where cd1.Constituency_ID=cd.Constituency_ID)
order by cd.EVM_Votes desc;

--Which candidate won and which candidate was the runner-up in each constituency of State for the 2024 elections?
with cte as(
select cd.Constituency_ID,cd.Candidate,cd.Total_Votes,ROW_NUMBER() over(partition by cd.Constituency_ID order by cd.Total_Votes desc) as candidate_rank_in_constituency 
from constituencywise_details cd)
select cr.Constituency_Name,(select cte.candidate from cte where cte.Constituency_ID=cr.constituency_id and candidate_rank_in_constituency=1) as winner, 
(select cte.candidate from cte where cte.Constituency_ID=cr.constituency_id and candidate_rank_in_constituency=2) as Runnerup 
from constituencywise_results cr 
join cte on cte.Constituency_ID=cr.Constituency_ID group by cr.Constituency_ID,cr.Constituency_Name;


WITH RankedCandidates AS (
    SELECT 
        cd.Constituency_ID,
        cd.Candidate,
        cd.Party,
        cd.EVM_Votes,
        cd.Postal_Votes,
        cd.EVM_Votes + cd.Postal_Votes AS Total_Votes,
        ROW_NUMBER() OVER (PARTITION BY cd.Constituency_ID ORDER BY cd.EVM_Votes + cd.Postal_Votes DESC) AS VoteRank
    FROM 
        constituencywise_details cd
    JOIN 
        constituencywise_results cr ON cd.Constituency_ID = cr.Constituency_ID
    JOIN 
        statewise_results sr ON cr.Parliament_Constituency = sr.Parliament_Constituency
    JOIN 
        states s ON sr.State_ID = s.State_ID
    WHERE 
        s.State = 'Maharashtra'
)

SELECT 
    cr.Constituency_Name,
    MAX(CASE WHEN rc.VoteRank = 1 THEN rc.Candidate END) AS Winning_Candidate,
    MAX(CASE WHEN rc.VoteRank = 2 THEN rc.Candidate END) AS Runnerup_Candidate
FROM 
    RankedCandidates rc
JOIN 
    constituencywise_results cr ON rc.Constituency_ID = cr.Constituency_ID
GROUP BY 
    cr.Constituency_Name
ORDER BY 
    cr.Constituency_Name;

--For the state of Maharashtra, what are the total number of seats, total number of candidates, 
--total number of parties, total votes (including EVM and postal), and the breakdown of EVM and postal votes?

select s.state,count(distinct cr.Winning_Candidate) as total_seats,count(distinct cd.Candidate) as total_candidates,
count(distinct cr.Party_ID) as total_parties,sum(cd.Total_Votes) as state_total_votes
from constituencywise_details cd
inner join constituencywise_results cr on cr.Constituency_ID=cd.Constituency_ID
inner join statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
inner join states s on s.State_ID=sr.State_ID
--where s.State='Maharashtra'
group by s.State
order by sum(cd.Total_Votes) desc;
