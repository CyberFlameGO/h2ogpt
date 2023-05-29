import os
import glob
from setuptools import setup
from pip._internal.req import parse_requirements


def get_files(data_dir):
    return [
        t for t in glob.glob(data_dir + "/**", recursive=True)
        if t[len(data_dir + "/"):] and os.path.isfile(t)
    ]


def get_requirements():
    return [
        str(r.requirement)
        for r in parse_requirements(
            "requirements.txt",
            session="hack",
        ) if not any(
            [
                exclude in str(r.requirement)
                for exclude in ["git+", "http://", "https://"]
            ]
        )
    ]


setup(
    name="h2ogpt",
    version="0.0.1",
    description="placeholder",
    long_description="placeholder",
    url="placeholder",
    # Author details
    author="H2O.ai",
    author_email="placeholder",
    license="placeholder",
    classifiers=[
        "Programming Language :: Python :: 3.10",
    ],
    keywords=[
        "machine learning",
        "data science",
    ],
    python_requires=">=3.7,<3.11",
    install_requires=get_requirements(),
    tests_require=[],
    packages=["h2ogpt"],
    package_dir={
        "h2ogpt": "",
    },
    package_data={
        "h2ogpt": ["data/**", "models/**", "spaces/**"]
    },
    entry_points={
        "console_scripts": [
            "h2ogpt_finetune=h2ogpt.finetune:entrypoint_main",
            "h2ogpt_generate=h2ogpt.generate:entrypoint_main",
        ],
    },
)
