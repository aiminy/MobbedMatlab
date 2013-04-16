function test_suite = testEEG  %#ok<STOUT>
initTestSuite;

% Function executed before each test
function tStruct = setup %#ok<DEFNU>

% Structure that holds Mobbed connection object constructor arguments 
tStruct = struct('name', 'testdb', 'url', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);

% Create connection object (create database first if doesn't exist)
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

% Get EEG modality uuid
m = getdb(DB, 'modalities', inf);
mNames = {m.modality_name};
pos = strcmp('EEG', mNames);
uuids = {m.modality_uuid};
tStruct.mUUID = uuids{pos};

% Function executed after each test
function teardown(tStruct) %#ok<DEFNU>
try
    tStruct.DB.commit();
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testEEGChanlocsAndEvents(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a EEG dataset with chanlocs and events\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'EEG - chanlocs and events';
s1.data = EEG; 
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, false); 
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));

function testEEGNoChanlocs(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a EEG dataset with no chanlocs\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB); 
s1.dataset_name = 'EEG - no chanlocs';
s1.data = EEG;
s1.data.chanlocs = [];
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, false); 
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));
assertTrue(isempty(s2.data.chanlocs));

function testEEGNoEvents(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a EEG dataset with no events\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB); 
s1.dataset_name = 'EEG - no events';
s1.data = EEG;
s1.data.event = [];
s1.dataset_modality_uuid = tStruct.mUUID;
UUIDs = mat2db(DB, s1, false); 
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));
assertTrue(isempty(s2.data.event));

function testEEGModalityName(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a EEG dataset using the modality name\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'EEG - modality name';
s1.data = EEG; 
s1.dataset_modality_uuid = 'EEG';
UUIDs = mat2db(DB, s1, false); 
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));

function testEEGDefaultModality(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a EEG dataset using the default EEG modality\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB);
s1.dataset_name = 'EEG - default modality';
s1.data = EEG; 
UUIDs = mat2db(DB, s1, false); 
s2 = db2mat(DB, UUIDs);
assertTrue(isequal(s1.data,s2.data));

function testEEGNoUniqueEventTypes(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a EEG dataset that reuses event types\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB); 
s1.dataset_name = 'EEG - original event types';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents1] = mat2db(DB, s1, false); 
s2 = db2mat(DB); 
s2.dataset_name = 'EEG - reuses event types';
s2.data = EEG;
s2.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents2] = mat2db(DB, s2, false, 'EventTypes', uniqueEvents1);
assertTrue(isequal(length(uniqueEvents1), length(uniqueEvents2)));

function testEEGUniqueEventTypes(tStruct) %#ok<DEFNU>
fprintf('\nIt should store a EEG dataset that has unique event types\n');
DB = tStruct.DB;
load eeglab_data_ch.mat;
s1 = db2mat(DB); 
s1.dataset_name = 'EEG - original event types';
s1.data = EEG;
s1.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents1] = mat2db(DB, s1, false); 
s2 = db2mat(DB); 
s2.dataset_name = 'EEG - unique event types';
s2.data = EEG;
s2.data.event(1).type = 'unique event type 1';
s2.data.event(2).type = 'unique event type 2';
s2.dataset_modality_uuid = tStruct.mUUID;
[~, uniqueEvents2] = mat2db(DB, s2, false, 'EventTypes', uniqueEvents1);
assertTrue(isequal(length(uniqueEvents1) + 2, length(uniqueEvents2)));