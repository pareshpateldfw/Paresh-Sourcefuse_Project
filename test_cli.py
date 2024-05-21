import unittest
from unittest.mock import patch, MagicMock
from click.testing import CliRunner
from cli import cli, list_s3_files, list_ecs_versions

class TestCLI(unittest.TestCase):

    @patch('cli.s3_client')
    def test_list_s3_files(self, mock_s3_client):
        mock_s3_client.list_objects_v2.return_value = {
            'Contents': [{'Key': 'file1.txt'}, {'Key': 'file2.txt'}]
        }
        runner = CliRunner()
        result = runner.invoke(list_s3_files, ['test-bucket'])
        self.assertIn('file1.txt', result.output)
        self.assertIn('file2.txt', result.output)
        self.assertEqual(result.exit_code, 0)

    @patch('cli.ecs_client')
    def test_list_ecs_versions(self, mock_ecs_client):
        mock_ecs_client.describe_services.return_value = {
            'services': [{'taskDefinition': 'arn:aws:ecs:region:account-id:task-definition/test-service:1'}]
        }
        mock_ecs_client.list_task_definitions.return_value = {
            'taskDefinitionArns': [
                'arn:aws:ecs:region:account-id:task-definition/test-service:1',
                'arn:aws:ecs:region:account-id:task-definition/test-service:2'
            ]
        }
        runner = CliRunner()
        result = runner.invoke(list_ecs_versions, ['test-cluster', 'test-service'])
        self.assertIn('arn:aws:ecs:region:account-id:task-definition/test-service:1', result.output)
        self.assertIn('arn:aws:ecs:region:account-id:task-definition/test-service:2', result.output)
        self.assertEqual(result.exit_code, 0)

if __name__ == '__main__':
    unittest.main()
