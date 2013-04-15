function test_suite = testCreatedb %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'hostname', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);
try
    tStruct.DB = Mobbed(tStruct.name, tStruct.hostname, tStruct.user, ...
        tStruct.password, false);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.hostname, tStruct.user, ...
        tStruct.password, 'mobbed.sql', false);
    tStruct.DB = Mobbed(tStruct.name, tStruct.hostname, tStruct.user, ...
        tStruct.password, false);
end

function testcreatedbAlreadyExist(tStruct) %#ok<DEFNU>
fprintf(['\nIt should throw an exception when creating a database that' ...
    ' already exists']);
assertExceptionThrown(...
    @() error(Mobbed.createdb(tStruct.name, tStruct.hostname, ...
    tStruct.user, tStruct.password, 'mobbed.sql', false)), ...
    'MATLAB:maxlhs');