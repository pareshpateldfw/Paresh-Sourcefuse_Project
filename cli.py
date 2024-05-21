import click
import boto3

session = boto3.Session(region_name='us-west-2')

# Initialize AWS clients
s3_client = boto3.client('s3')
ecs_client = boto3.client('ecs')

@click.group()
def cli():
    pass

@click.command()
@click.argument('bucket_name')
def list_s3_files(bucket_name):
    """List files in an S3 bucket."""
    try:
        response = s3_client.list_objects_v2(Bucket=bucket_name)
        if 'Contents' in response:
            for obj in response['Contents']:
                click.echo(obj['Key'])
        else:
            click.echo(f"No files found in bucket {bucket_name}")
    except Exception as e:
        click.echo(f"Error: {e}")

@click.command()
@click.argument('cluster_name')
@click.argument('service_name')
def list_ecs_versions(cluster_name, service_name):
    """List versions of ECS task definition for a service."""
    try:
        response = ecs_client.describe_services(cluster=cluster_name, services=[service_name])
        task_def_arn = response['services'][0]['taskDefinition']
        
        task_definitions = ecs_client.list_task_definitions(familyPrefix=task_def_arn.split('/')[1])
        for task_def in task_definitions['taskDefinitionArns']:
            click.echo(task_def)
    except Exception as e:
        click.echo(f"Error: {e}")

# Add commands to CLI group
cli.add_command(list_s3_files)
cli.add_command(list_ecs_versions)

if __name__ == '__main__':
    cli()
