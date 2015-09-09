insert into "lectures_room" ("building", "number")
select * from unnest('{A1, A2, A3, B1, B2, B3, B4, C1, C2, C3}'::text[])
left join generate_series(1, ceil(5 + random() * 15)::integer) on true;

create temporary table "titles"("title" text) on commit drop;

insert into "titles" values
('Abstract Mathematics As Expressed In Rural Neo-Pagan Drama'),
('Activisim In The Feminist World: Critical Thinking and Abstraction'),
('Ad-Hoc Investigation Of Humanist Political Correctness & The Lentini-Smeets Postulate'),
('Ad-Hoc Investigation Of Sumerian Poetry: Cross-Cultural Awareness and Evaluation'),
('Advanced Topics In Incan Folklore: A Figure Of Evolution In Todays Society'),
('Advanced Topics In Middle Class Mexican Sculptures'),
('Advanced Topics In Synchronized Swimming: Ideas In Transition'),
('Advanced Topics In The Feminist Latino Transformation In Modern America'),
('Aesthetic Art: A Journey Of Self-Actualization'),
('Aesthetic Equality In The United States'),
('Aesthetic Multi-Ethnic Symbols In The United States'),
('Aesthetic Political Correctness: A Process Approach'),
('African-American Multiculturalism Issues In Modern America'),
('African-American Religion: Warwicks Hypothesis At Work'),
('African Drama As A Reformist Genre'),
('African Environmentalism Values In The Real World'),
('African Globalism Affairs In The Postmodern World'),
('African Retrospectives: A Symbol Explored In American Literature'),
('Age, Age, And Politics In The Modern Age: Ideas In Conflict'),
('American Folklore Interpretation: A Metaphor Of Etruscan Art'),
('American Symbols: Ideas In Conflict'),
('Anger & Passion In The Postmodern World'),
('Anthropology As Explored In Liberated African Folklore'),
('Aquatic Ballet In The Aesthetic World: Different Points Of View'),
('Aquatic Ballet In Todays Society: Contemporary Theories'),
('Art Of Multi-Ethnic Diversity: Ideas In Transition'),
('Asian Music As A Postmodern Genre'),
('Asian Perspectives: The Big Picture'),
('Asian Sexuality Ethics In The Modern Age'),
('Atheist Expression: The Untold Story'),
('Basketweaving In The Modern Age: From Parker To Highley'),
('Birdwatching In The Liberal World: Analysis and Interpretation'),
('Bisexual Asian Literature In The Liberated World'),
('Brief Survey Of Death In Native American Architecture: A Metaphor Of Byzantine Endeavors'),
('Brief Survey Of Professional Sports: A Process Approach'),
('Brief Survey Of Urban Latino Life'),
('Cardplaying In The Postmodern World: A Process Approach'),
('Chinese Poetry Interpretation: The Big Picture'),
('Classical Cubism & Intellectualism In Modern America'),
('Classical Realism & Realism In The Postmodern Era'),
('Classic American Literature In The American Landscape: Critical Issues Facing The 21st Century Individual'),
('Community, Class, And Sex In European Mythology: A Presentation Expressed In 21st Century Art'),
('Concepts In Daytime Soap Operas: A Process Approach'),
('Concepts In Gay & Lesbian Australian Dance'),
('Concepts In The Jerry Springer Show: Synergy, Empowerment, and Development'),
('Conflict, Race, And Class In Multi-Ethnic Art: Ideas In Conflict'),
('Conflict, Struggle, And Culture In The Postmodern World: A Symbol Of Aztec Expression'),
('Contemporary African-American Thought: Policy In The Real World'),
('Contemporary Asian Affairs & Expression'),
('Contemporary Asian Culture: A Study Expressed In Contemporary Art'),
('Contemporary Australian Traditions: The Strong Conjecture At Work'),
('Contemporary Female Ideas: Contemporary Theories'),
('Contemporary French Ethics & Affairs'),
('Contemporary Italian Issues & Landscapes'),
('Contemporary Japanese Perspectives & Society'),
('Contemporary Japanese Retrospectives & Morals'),
('Contemporary Latino Life & Civilization'),
('Contemporary Latvian Endeavors: An Interdisciplinary Study'),
('Contemporary Pacific Islander Retrospectives & Morals'),
('Contemporary Scandinavian Morals: A Process Approach'),
('Crime & Trauma In The 21st Century'),
('Critical Perspectives In Romanticism & Multiculturalism In The 21st Century'),
('Critical Perspectives In Synchronized Swimming: A Paradigm Shift'),
('Critical Perspectives In The American Civil War: The Untold Story'),
('Critical Perspectives In The Jerry Springer Show: Different Points Of View'),
('Critical Perspectives In The War Of 1812: A Figure Of Sexuality In Todays Society'),
('Culture, Community, And Status In Chinese Music: The Big Picture'),
('Culture Of Elbonian Diversity: A Quest For Discovery'),
('Darwinism In The Postmodern Era: A Process Approach'),
('Daytime Soap Operas In Recent Times: Ideas In Transition'),
('Death & Passion In Recent Times'),
('Diversity In The 21st Century: Policy In Recent Times'),
('Dynamic Exploration Of Post-Egyptian Drama: Context and Paradigms'),
('Dynamic Exploration Of Synchronized Swimming: An Interdisciplinary Approach'),
('Dynamic Exploration Of The Culinary Experience: Empowerment, Relationships, and Analysis'),
('Elbonian Images: A Figure Of Homosexuality In The 21st Century'),
('Ethnicity In Modern America: The Eastern Neo-Pagan Experience'),
('Ethnicity In Recent Times: The Gay & Lesbian Australian Experience'),
('Ethnicity In The Modern Age: The Middle Class Hispanic Experience'),
('Ethnicity In The Postmodern World: The Upper Class Scandinavian Condition'),
('Ethnicity In The United States: The Transgender Female Experience'),
('Exploration Of Early Hittite Mythology: Abbeys Theorem At Work'),
('Exploration Of Suicide In Female Literature: A Symbol Explored In 20th Century Music'),
('Family, Conflict, And Sex In The Reformist World: Different Points Of View'),
('Female Paganism Landscapes In Modern America'),
('Female Paintings Interpretation: Perspectives and Critical Thinking'),
('Female Self-Actualization Endeavors In Todays Society'),
('Feminist Feminism In Todays Society'),
('Feminist Globalism In Modern Dance'),
('Feminist Marxism In Modern Architecture'),
('Feminist Paganism In Modern Poetry'),
('Feminist Poverty And Aesthetic Queer Theory In The American Landscape'),
('Foundations Of Liberated Early Realism & The Paulsen-Donnelly-Pleis Conjecture'),
('Foundations Of Post-Hittite Folklore: Understanding and Context'),
('Foundations Of Pre-Viking Mythology: Policy In The Modern Age'),
('Foundations Of Queer Theory & Poverty In The Liberal World'),
('Foundations Of The Simpsons: A Figure Of Sexuality In The Modern Age'),
('Fundamentalism In The Postmodern World: Modern Ideas'),
('Gay & Lesbian German Retrospectives In The Real World'),
('Globalism & Fundamentalism In Todays Society'),
('Globalism & Poverty In The 21st Century'),
('Greek Music As The Foundations Of 21st Century Rural Sociology'),
('Greek Music As The Foundations Of Modern Computer Science'),
('Hate & Anger In The Postmodern Era'),
('Hispanic Expression: The Big Picture'),
('Home Economics In Modern America: A Journey Of Thought'),
('Home Economics In The 21st Century: Critical Issues Facing The 20th Century American'),
('Homosexual European Ideas Since 1853'),
('Homosexuality & Globalism In Todays Society'),
('Homosexuality & Socialism In Todays Society'),
('Humanist Retrospectives: A Presentation Expressed In American Drama'),
('Infidelity & Infidelity In The American Landscape'),
('Intellectualism & Communism In Modern America'),
('Introduction To Global Warming: Policy In The 21st Century'),
('Introduction To Southern Atheist Music'),
('Introduction To The Suburban Neo-Pagan Transformation In The Postmodern World'),
('Issues Of Polytheistic Feminism: The Ohlsen Postulate At Work'),
('Italian Art As A Progressive Genre'),
('Italian Poetry As A Aesthetic Genre'),
('Landscapes Of African Multiculturalism: Critical Issues Facing The 21st Century Woman'),
('Landscapes Of Russian Equality: Policy In The 21st Century'),
('Latvian Art As A Humanist Genre'),
('Latvian Dance Interpretation: A Process Approach'),
('Latvian Fundamentalism Landscapes In Recent Times'),
('Latvian Paintings As A Reformist Genre'),
('Liberal Endeavors: Different Points Of View'),
('Liberal Ethics: Policy In The Progressive World'),
('Liberal Images: A Symbol Of Greek Retrospectives'),
('Liberal Sexuality And Humanist Environmentalism In The 21st Century'),
('Liberal Thought: The Big Picture'),
('Liberated Chinese Endeavors Since 1806'),
('Liberated Diversity In The Real World'),
('Liberated Globalism: The Big Picture'),
('Liberated Queer Theory: A Symbol Of Paganism In Todays Society'),
('Liberated Sexuality And Humanist Paganism In The Real World'),
('Liberated Thought: Different Points Of View'),
('Literature Of Pre-Viking Art: Critical Issues Facing The Modern Minority'),
('Literature Of Reformist Activisim In The United States'),
('Marxism & Darwinism In The Reformist World'),
('Marxism In The 21st Century: Ideas In Conflict'),
('Masterpieces Of Bisexual African Paintings'),
('Masterpieces Of Eastern Australian Architecture'),
('Masterpieces Of Humanist Mexican Literature'),
('Masterpieces Of Inner City Pacific Islander Mythology'),
('Masterpieces Of Rural Australian Drama'),
('Masterpieces Of Rural French Poetry'),
('Masterpieces Of Southern Asian Literature'),
('Masterpieces Of Suburban European Literature'),
('Masterpieces Of Upper Class American Paintings'),
('Masterpieces Of Western Middle Eastern Paintings'),
('Meta-Physics Of Early Roman Poetry: Modern Theories'),
('Meta-Physics Of Gay & Lesbian Minority Traditions'),
('Meta-Physics Of Hate In Russian Drama: A Study Of Viking Landscapes'),
('Meta-Physics Of Post-Egyptian Poetry: From Haddix To Marbach'),
('Meta-Physics Of Suicide In Mexican Paintings: Myth & Reality'),
('Meta-Physics Of The Rural Hispanic Transformation In The Modern Age'),
('Meta-Physics Of The Southern Pacific Islander Transformation In Modern Society'),
('Mexican Folklore As A Populist Genre'),
('Mexican Religion: Policy In The Real World'),
('Microbiology As Explored In Western Elbonian Poetry'),
('Middle Class Polytheistic Art In Recent Times'),
('Minority Symbols: The Untold Story'),
('Music Of Chinese Fundamentalism: A Figure Of Homosexuality In Modern Society'),
('Neo-Pagan Art As A Postmodern Genre'),
('Neo-Pagan Dance As A Radical Genre'),
('Pacific Islander Folklore Interpretation: A Process Approach'),
('Passion & Horror In The Real World'),
('Perspectives In Progressive Sexuality In The American Landscape'),
('Perspectives In The Spanish-American War: Contemporary Theories'),
('Philosophy Of Sportsmanship: A Process Approach'),
('Philosophy Of The Bisexual Female Metamorphosis In The Postmodern World'),
('Philosophy Of The Inner City Neo-Pagan Campaign In The American Landscape'),
('Political Cartoons In Modern America: Myth & Reality'),
('Political Cartoons In The Real World: The Untold Story'),
('Politics, Community, And Family In Modern America: Relationships, Synthesis, and Empowerment'),
('Politics, Culture, And Family In Polytheistic Literature: The Untold Story'),
('Polytheistic Architecture As A Liberal Genre'),
('Polytheistic Life: A Study Of Egyptian Civilization'),
('Polytheistic Literature: The Big Picture'),
('Populist Society: An Interdisciplinary Study'),
('Populist Society: Ideas In Transition'),
('Pornography In The American Landscape: Modern Theories'),
('Post-Dadaism In The 21st Century: An Interdisciplinary Study'),
('Postmodern Dadaism: Policy In The Postmodern World'),
('Postmodern Diversity: Ideas In Conflict'),
('Postmodern Homosexuality In The Postmodern World'),
('Postmodern Marxism: Analysis and Critical Thinking'),
('Principles Of Classic Chinese Literature: Modern Ideas'),
('Principles Of Marxism & Queer Theory In The Postmodern Era'),
('Progressive Issues: A Metaphor Interpreted In American Drama'),
('Progressive Literature: A Paradigm Shift'),
('Progressive Marxism In Modern Paintings'),
('Progressive Multiculturalism In Modern America'),
('Progressive Realism In Modern Mythology'),
('Progressive Religion: Understanding, Understanding, and Analysis'),
('Psychology Of Cardplaying: A Symbol Of Renaissance Literature'),
('Psychology Of Early Aztec Paintings: An Interdisciplinary Study'),
('Psychology Of Eastern Female Endeavors'),
('Psychology Of Evolution & Classical Cubism In Todays Society'),
('Psychology Of Sportsmanship: From Shirk To Sarel'),
('Psychology Of The JFK Assasination: Myth & Reality'),
('Psychology Of Transgender Neo-Pagan Architecture'),
('Quantitative Methods In Environmentalism & Political Correctness In Todays Society'),
('Quantitative Methods In Humanist Equality In The Real World'),
('Quantitative Methods In Rural Native American Endeavors'),
('Quantitative Methods In Westward Expansion: The Brueckner-Thibaut Principle At Work'),
('Quantum String Theory As Explored In Middle Class Elbonian Art'),
('Queer Theory In The Postmodern World: Evaluation and Synthesis'),
('Queer Theory & Self-Actualization In The 21st Century'),
('Race, Age, And Family In The Populist World: A Presentation Of Mayan Issues'),
('Race, Conflict, And Culture In Australian Music: Evaluation and Evaluation'),
('Race, Struggle, And Race In Modern Society: A Paradigm Shift'),
('Radical Diversity In Modern Drama'),
('Radical Diversity In Modern Sculptures'),
('Radical Environmentalism And Postmodern Pre-Romanticism In The Real World'),
('Radical French Ethics In The Postmodern Era'),
('Reformist Activisim In Recent Times'),
('Reformist Darwinism In Modern Society'),
('Reformist Globalism In Modern Society'),
('Reformist Lifestyles: Empowerment and Cross-Cultural Perspectives'),
('Reformist Morals: Critical Issues Facing The Contemporary Person'),
('Research Capstone In Greek Architecture: Evaluation, Context, and Practice'),
('Research Capstone In Manifest Destiny: What Is To Be Learned From It?'),
('Research Capstone In Passion In Italian Dance: Context and Synthesis'),
('Research Capstone In Populist Evolution In The 21st Century'),
('Research Capstone In The JFK Assasination: The Bikki Theory At Work');

with
    "titles" as (
        select
            row_number() over () as "id",
            "title"
        from
            "titles"
    ),
    "random_data" as (
        select
            floor(random() * (select max(id)-min(id) from "lectures_room"))::integer as "room_id",
            floor(random() * (select max(id)-min(id) from "titles"))::integer as "title_id",
            date_trunc('hour', '2015-01-01'::timestamp + (random()*365 || ' days')::interval) as date
        from generate_series(1, 240 * (select count(*) from "lectures_room"))
    )
insert into "lectures_lecture"("date", "title", "room_id")
select
    "date",
    (select "title" from "titles" where "id" = "title_id"+1),
    (select min("id")+"room_id" from "lectures_room")
from "random_data";