-- { echoOn }

-- basic tests

-- expected output: {'age':'31','name':'neymar','nationality':'brazil','team':'psg'}
WITH
    extractKeyValuePairs('name:neymar, age:31 team:psg,nationality:brazil') AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- keys and values starting with number, underscore and other special characters
-- expected output: {'$nationality':'@brazil','1name':'neymar','4ge':'31','_team':'_psg'}
WITH
    extractKeyValuePairs('1name:neymar, 4ge:31 _team:_psg,$nationality:@brazil') AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- only special characters
-- expected output: {'#':'#','$':'$','@':'@','_':'_'}
WITH
    extractKeyValuePairs('_:_, @:@ #:#,$:$') AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- special (not control) characters in the middle of elements
-- expected output: {'age':'3!','name':'ney!mar','nationality':'br4z!l','t&am':'@psg'}
WITH
    extractKeyValuePairs('name:ney!mar, age:3! t&am:@psg,nationality:br4z!l') AS s_map,
        CAST(
            arrayMap(
                (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
            ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- non-standard escape characters (i.e not \n, \r, \t and etc), back-slash should be preserved
-- expected output: {'amount\\z':'$5\\h','currency':'\\$USD'}
WITH
    extractKeyValuePairs('currency:\$USD, amount\z:$5\h') AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- invalid escape sequence, should be discarded
-- expected output: {'valid_key':'valid_value'}
WITH
    extractKeyValuePairs('valid_key:valid_value key:invalid_val\\', ':', ' ', '"', 1) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- standard escape sequences are covered by unit tests

-- simple quoting
-- expected output: {'age':'31','name':'neymar','team':'psg'}
WITH
    extractKeyValuePairs('name:"neymar", "age":31 "team":"psg"') AS s_map,
        CAST(
            arrayMap(
                (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
            ),
        'Map(String,String)'
    ) AS x
SELECT
    x;

-- empty values
-- expected output: {'age':'','name':'','nationality':''}
WITH
    extractKeyValuePairs('name:"", age: , nationality:') AS s_map,
    CAST(
        arrayMap(
            (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
        ),
        'Map(String,String)'
    ) AS x
SELECT
    x;

-- empty keys
-- empty keys are not allowed, thus empty output is expected
WITH
    extractKeyValuePairs('"":abc, :def') AS s_map,
    CAST(
        arrayMap(
            (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
        ),
        'Map(String,String)'
    ) AS x
SELECT
    x;

-- semi-colon as pair delimiter
-- expected output: {'age':'31','name':'neymar','team':'psg'}
WITH
    extractKeyValuePairs('name:neymar;age:31;team:psg;invalid1:invalid1,invalid2:invalid2', ':', ';') AS s_map,
    CAST(
        arrayMap(
            (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
        ),
        'Map(String,String)'
    ) AS x
SELECT
    x;

-- both comma and semi-colon as pair delimiters
-- expected output: {'age':'31','last_key':'last_value','name':'neymar','nationality':'brazil','team':'psg'}
WITH
    extractKeyValuePairs('name:neymar;age:31;team:psg;nationality:brazil,last_key:last_value', ':', ';,') AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- single quote as quoting character
-- expected output: {'age':'31','last_key':'last_value','name':'neymar','nationality':'brazil','team':'psg'}
WITH
    extractKeyValuePairs('name:\'neymar\';\'age\':31;team:psg;nationality:brazil,last_key:last_value', ':', ';,', '\'') AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- NO ESCAPING TESTS
-- expected output: {'age':'31','name':'neymar','nationality':'brazil','team':'psg'}
WITH
    extractKeyValuePairs('name:neymar, age:31 team:psg,nationality:brazil', ':', ', ', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- special (not control) characters in the middle of elements
-- expected output: {'age':'3!','name':'ney!mar','nationality':'br4z!l','t&am':'@psg'}
WITH
    extractKeyValuePairs('name:ney!mar, age:3! t&am:@psg,nationality:br4z!l', ':', ', ', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- non-standard escape characters (i.e not \n, \r, \t and etc), it should accept everything
-- expected output: {'amount\\z':'$5\\h','currency':'\\$USD'}
WITH
    extractKeyValuePairs('currency:\$USD, amount\z:$5\h', ':', ', ', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- standard escape sequences, it should return it as it is
-- expected output: {'key1':'header\nbody','key2':'start_of_text\tend_of_text'}
WITH
    extractKeyValuePairs('key1:header\nbody key2:start_of_text\tend_of_text', ':', ', ', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- standard escape sequences are covered by unit tests

-- simple quoting
-- expected output: {'age':'31','name':'neymar','team':'psg'}
WITH
    extractKeyValuePairs('name:"neymar", "age":31 "team":"psg"', ':', ', ', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- empty values
-- expected output: {'age':'','name':'','nationality':''}
WITH
    extractKeyValuePairs('name:"", age: , nationality:', ':', ', ', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- empty keys
-- empty keys are not allowed, thus empty output is expected
WITH
    extractKeyValuePairs('"":abc, :def', ':', ', ', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- semi-colon as pair delimiter
-- expected output: {'age':'31','name':'neymar','nationality':'brazil','team':'psg'}
WITH
    extractKeyValuePairs('name:neymar;age:31;team:psg;nationality:brazil', ':', ';', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- both comma and semi-colon as pair delimiters
-- expected output: {'age':'31','last_key':'last_value','name':'neymar','nationality':'brazil','team':'psg'}
WITH
    extractKeyValuePairs('name:neymar;age:31;team:psg;nationality:brazil,last_key:last_value', ':', ';,', '"', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- single quote as quoting character
-- expected output: {'age':'31','last_key':'last_value','name':'neymar','nationality':'brazil','team':'psg'}
WITH
    extractKeyValuePairs('name:\'neymar\';\'age\':31;team:psg;nationality:brazil,last_key:last_value', ':', ';,', '\'', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;

-- { echoOff }

-- cross parameter validation tests
-- should fail because key value delimiter conflicts with pair delimiters
WITH
    extractKeyValuePairs('not_important', ':', ',:', '\'', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x; -- {serverError BAD_ARGUMENTS}

-- should fail because key value delimiter conflicts with quoting characters
WITH
    extractKeyValuePairs('not_important', ':', ',', '\':', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x; -- {serverError BAD_ARGUMENTS}

-- should fail because pair delimiters conflicts with quoting characters
WITH
    extractKeyValuePairs('not_important', ':', ',', ',', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x; -- {serverError BAD_ARGUMENTS}

-- should fail because pair delimiters can contain at most 8 characters
WITH
    extractKeyValuePairs('not_important', ':', '123456789', '\'', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x; -- {serverError BAD_ARGUMENTS}

-- should not fail because pair delimiters contains 8 characters, which is within the limit
WITH
    extractKeyValuePairs('not_important', ':', '12345678', '\'', 0) AS s_map,
    CAST(
            arrayMap(
                    (x) -> (x, s_map[x]), arraySort(mapKeys(s_map))
                ),
            'Map(String,String)'
        ) AS x
SELECT
    x;
