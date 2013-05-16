function test_suite = testExtractdb %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);
try
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, false);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, 'mobbed.sql', false);
    DB = Mobbed(tStruct.name, tStruct.url, tStruct.user, ...
        tStruct.password, false);
end
tStruct.DB = DB;

% Create event types
e1 = getdb(DB, 'event_types', 0);
e1.event_type = 'event type 1';
e1.event_type_description = 'event type description: event type 1';
uuid1 = putdb(DB, 'event_types', e1);

e2 = getdb(DB, 'event_types', 0);
e2.event_type = 'event type 2';
e2.event_type_description = 'event type description: event type 2';
uuid2 = putdb(DB, 'event_types', e2);

e3 = getdb(DB, 'event_types', 0);
e3.event_type = 'event type 3';
e3.event_type_description = 'event type description: event type 3';
uuid3 = putdb(DB, 'event_types', e3);

e4 = getdb(DB, 'event_types', 0);
e4.event_type = 'event type 4';
e4.event_type_description = 'event type description: event type 4';
uuid4 = putdb(DB, 'event_types', e4);

d = getdb(DB, 'datasets', 0);
d.dataset_name = randseq(20);
d.dataset_description = 'reference dataset description ';
d.dataset_uuid = putdb(DB, 'datasets', d);
datasetUuid = d.dataset_uuid{1};

% Create events
e1 = getdb(DB, 'events', 0);
e1.event_entity_uuid = datasetUuid;
e1.event_entity_class = 'datasets';
e1.event_type_uuid = uuid1{1};
e1.event_start_time = 1;
e1.event_end_time = 1;
e1.event_position = 1;
e1.event_certainty = 1;
putdb(DB, 'events', e1);

e2 = getdb(DB, 'events', 0);
e2.event_entity_uuid = datasetUuid;
e2.event_entity_class = 'datasets';
e2.event_type_uuid = uuid2{1};
e2.event_start_time = 2;
e2.event_end_time = 2;
e2.event_position = 2;
e2.event_certainty = 1;
putdb(DB, 'events', e2);

e3 = getdb(DB, 'events', 0);
e3.event_entity_uuid = datasetUuid;
e3.event_entity_class = 'datasets';
e3.event_type_uuid = uuid3{1};
e3.event_start_time = 3;
e3.event_end_time = 3;
e3.event_position = 3;
e3.event_certainty = 1;
putdb(DB, 'events', e3);

tStruct.DB.commit();
tStruct.event_type_uuids = [uuid1(:),uuid2(:),uuid3(:),uuid4(:)];

function teardown(tStruct) %#ok<DEFNU>
tStruct.DB.close();

function testDefaultRange(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for extractdb with default range:\n');
fprintf('It should extract all events within the default range\n');
DB = tStruct.DB;
[mStructure, extStructure] = extractdb(DB, 'events', [], 'events', [], ...
    inf);
fprintf(['--It should return a structure array containing the' ...
    ' events found in the default range\n']);
assertTrue(~isempty(mStructure));
fprintf(['--It should return a structure array containing the unique' ...
    ' events found in the default range\n']);
assertTrue(~isempty(extStructure));

function testLimit(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for extractdb with limit:\n');
fprintf(['It should extract at most the limit of events found in the' ...
    ' default range\n']);
DB = tStruct.DB;
limit = 1;
[mStructure, extStructure] = extractdb(DB, 'events', [], 'events', [], ...
    limit);
fprintf(['--It should return a structure array the size of limit' ...
    ' containing the events found in the default range\n']);
assertTrue(~isempty(mStructure));
assertTrue(isequal(length(mStructure), limit));
fprintf(['--It should return a structure array the size of limit' ...
    ' containing the unique events found in the default range\n']);
assertTrue(~isempty(extStructure));
assertTrue(isequal(length(extStructure), limit));

function testInStructure(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for extractdb with inStructure:\n');
fprintf(['It should extract all events within the default range with' ...
    ' search qualifications specified in inStructure\n']);
DB = tStruct.DB;
% only look for interrelated events in type 1 events
inStructure.event_type_uuid = tStruct.event_type_uuids{1};
[mStructure, extStructure] = extractdb(DB, 'events', inStructure, ...
    'events', [], inf);
fprintf(['--It should return a structure array containing the' ...
    ' events found in the default range\n']);
assertTrue(~isempty(mStructure));
fprintf(['--It should return a structure array containing the unique' ...
    ' events found in the default range\n']);
assertTrue(~isempty(extStructure));

function testOutStructure(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for extractdb with outStructure:\n');
fprintf(['It should extract all events within the default range with' ...
    ' search qualifications specified in outStructure\n']);
DB = tStruct.DB;
% only look for type 2 events in all events
outStructure.event_type_uuid = tStruct.event_type_uuids{2};
[mStructure, extStructure] = extractdb(DB, 'events', [], 'events', ...
    outStructure, inf);
fprintf(['--It should return a structure array containing the' ...
    ' events found in the default range\n']);
assertTrue(~isempty(mStructure));
fprintf(['--It should return a structure array containing the unique' ...
    ' events found in the default range\n']);
assertTrue(~isempty(extStructure));

function testInStructureAndOutStructure(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for extractdb with inStructure and outStructure:\n');
fprintf(['It should extract all events within the default range with' ...
    ' search qualifications specified in inStructure and outStructure\n']);
DB = tStruct.DB;
% only look for type 2 events in type 1 events
inStructure.event_type_uuid = tStruct.event_type_uuids{1};
outStructure.event_type_uuid = tStruct.event_type_uuids{2};
[mStructure, extStructure] = extractdb(DB, 'events', inStructure, ...
    'events', outStructure, inf);
fprintf(['--It should return a structure array containing the' ...
    ' events found in the default range\n']);
assertTrue(~isempty(mStructure));
fprintf(['--It should return a structure array containing the unique' ...
    ' events found in the default range\n']);
assertTrue(~isempty(extStructure));