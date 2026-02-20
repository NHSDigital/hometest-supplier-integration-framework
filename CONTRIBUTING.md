# Contributing

Thank you for your interest in contributing to this project! Please follow the guidelines below.

## Getting Started

### Fork the Repository

1. Fork this repository to your own GitHub account
2. Clone your forked repository locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/hometest-supplier-integration-framework.git
   cd hometest-supplier-integration-framework
   ```
3. Add the original repository as an upstream remote:
   ```bash
   git remote add upstream https://github.com/NHSDigital/hometest-supplier-integration-framework.git
   ```

### GPG Commit Signing

All commits must be signed with a GPG key to ensure authenticity and integrity.

#### Setting up GPG Keys

##### macOS

1. Install `gnupg` & `pinentry-mac` with [Brew](https://brew.sh):

    ```bash
    brew upgrade
    brew install gnupg pinentry-mac
    sed -i '' '/^export GPG_TTY/d' ~/.zshrc
    echo export GPG_TTY=\$\(tty\) >> ~/.zshrc
    source ~/.zshrc
    PINENTRY_BIN=$(whereis -q pinentry-mac)
    mkdir -p ~/.gnupg
    touch ~/.gnupg/gpg-agent.conf
    sed -i '' '/^pinentry-program/d' ~/.gnupg/gpg-agent.conf
    echo "pinentry-program ${PINENTRY_BIN}" >> ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent
    ```

2. Create a new GPG key:

    ```bash
    gpg --full-generate-key
    ```

    1. Pick `(9) ECC (sign and encrypt)` then `Curve 25519` ([Ed25519](https://en.wikipedia.org/wiki/EdDSA#Ed25519) offers the strongest encryption at time of writing)
    2. Select a key expiry time (personal choice)
    3. `Real name` = Your GitHub handle
    4. `Email address` = An email address [registered against your GitHub account](https://github.com/settings/emails)
    5. Avoid adding a comment (this *may* prevent git from auto-selecting a key)
    6. Review your inputs and press enter `O` to confirm
    7. Define a passphrase for the key

3. Test the key is visible and export the PGP public key (to your clipboard):

    ```bash
    gpg -k # This should list the new key
    gpg --armor --export <my_email_address> | pbcopy
    ```

    > Your PGP public key is now in your clipboard!

4. [Add the public key to your GitHub account](https://github.com/settings/gpg/new) (`Settings` -> `SSH and GPG keys` -> `New GPG key`)

    > Note the `Key ID` as you'll need this in the next step.

5. Set your local git config to use GPG signing:

    ```bash
    git config user.email <my_email_address> # same one used during key generation
    git config user.name <github_handle>
    git config user.signingkey <key_id>
    git config commit.gpgsign true
    git config tag.gpgsign true
    ```

6. Test it works:

    1. Create a temporary branch of your favourite repository.
    2. Make an inconsequential whitespace change.
    3. Commit the change.
        1. You will be prompted for your GPG key passphrase - optionally select to add it to the macOS Keychain.
    4. Check the latest commit shows a successful signing:

        ```bash
        $ git log --show-signature -1
        ...
        gpg: Good signature from "<github_handle> <<my_email_address>>" [ultimate]
        Author: <github_handle> <<my_email_address>>
        ...
        ```

#### Windows/WSL

1. Install (as administrator) [Git for Windows](https://git-scm.com/download/win) (which includes Bash and GnuPG)
2. Open `Git Bash`
3. Create a new GPG key:

    ```bash
    gpg --full-generate-key
    ```

    1. Pick `(9) ECC (sign and encrypt)` then `Curve 25519` ([Ed25519](https://en.wikipedia.org/wiki/EdDSA#Ed25519) offers the strongest encryption at time of writing)

        > If you already had Git for Windows installed, and its version is between `2.5.0` and `2.30.x`, the `(9) ECC and ECC` option is available if you run `gpg --expert --full-generate-key`, however if you can upgrade to the latest version, this is advised.

    2. Select a key expiry time (personal choice)
    3. `Real name` = Your GitHub handle
    4. `Email address` = An email address [registered against your GitHub account](https://github.com/settings/emails)

        > If instead you opt for the private *@users.noreply.github.com* email address, consider enabling `Block command line pushes that expose my email`.

    5. Avoid adding a comment (this *may* prevent git from auto-selecting a key - see Troubleshooting section below)
    6. Review your inputs and press enter `O` to confirm
    7. A new window called pinentry will appear prompting you to enter a passphrase.

4. Test the key is visible and export the PGP public key (to your clipboard):

    ```bash
    gpg -k # This should list the new key
    gpg --armor --export <my_email_address> | clip
    ```

    > Your PGP public key is now in your clipboard!

5. [Add the public key to your GitHub account](https://github.com/settings/gpg/new) (`Settings` -> `SSH and GPG keys` -> `New GPG key`)

    > Note the `Key ID` as you'll need this in the next step.

6. Set your local git config to use GPG signing:

    ```bash
    git config user.email <my_email_address> # same one used during key generation
    git config user.name <github_handle>
    git config user.signingkey <key_id>
    git config commit.gpgsign true
    git config tag.gpgsign true
    ```

7. Now your key is created, make it available within Windows:

    1. Export the key:

        ```bash
        gpg --output <GitHub handle>.pgp --export-secret-key <my_email_address>
        ```

    2. Install (as administrator) [Gpg4win](https://www.gpg4win.org/) (which includes GnuPG and Kleopatra)

        > **Ensure both `GnuPG` and `Kleopatra` are installed!**

    3. Open Kleopatra -> `Import` -> Select the `<GitHub handle>.pgp` file created in the first step
    4. In `cmd`, test the key is visible and set your local git config to use GPG signing:

        ```bash
        gpg -k # This should list the new key
        git config user.email <my_email_address> # same one used during key generation
        git config user.name <github_handle>
        git config user.signingkey <key_id>
        git config commit.gpgsign true
        git config tag.gpgsign true
        ```

8. Now make it available within WSL:

    1. Within Ubuntu:

        ```bash
        sudo ln -s /mnt/c/Program\ Files\ \(x86\)/GnuPG/bin/gpg.exe /usr/local/bin/gpg
        sudo ln -s gpg /usr/local/bin/gpg2
        ```

    2. Close and reopen your Ubuntu terminal

    3. Test the key is visible and set your local git config to use GPG signing:

        ```bash
        gpg -k # This should list the new key
        git config user.email <my_email_address> # same one used during key generation
        git config user.name <github_handle>
        git config user.signingkey <key_id>
        git config commit.gpgsign true
        git config tag.gpgsign true
        ```

#### Git Config Partial

To avoid repeating git config steps across repositories or having it decalared globally, you can store your signing config in a reusable partial file.

1. Create a partial config file, e.g. `~/.gitconfig-signing`:

    ```ini
    [user]
        email = <my_email_address>
        name = <github_handle>
        signingkey = <key_id>
    [commit]
        gpgsign = true
    [tag]
        gpgsign = true
    ```

2. Include it in your global git config (`~/.gitconfig`), either always:

    ```bash
    git config --global include.path ~/.gitconfig-signing
    ```Or conditionally, e.g. only for repos under a specific directory:

    ```bash
    git config --global includeIf.gitdir:~/work/.path ~/.gitconfig-signing
    ```

3. You can then skip the `git config` steps in the GPG setup above, as the partial will handle them.

## Making Changes

1. Create a new branch from main: `git checkout -b feature/your-feature-name`
2. Make your changes and ensure all commits are signed
3. Push your changes to your fork
4. Create a Pull Request against the main repository

## Pull Request Requirements

1. All commits must be GPG signed
2. Include a clear description of the changes
3. Follow the existing code style and conventions
4. Ensure tests pass (if applicable)
