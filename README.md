# twostamp

Prove that files existed, unchanged, at a point in time. With two independent timestamps in one command:

- **RFC 3161** from a trusted timestamp authority (freetsa.org by default), valid in seconds
- **OpenTimestamps**, anchored in the Bitcoin blockchain, confirmed after a few hours

Only SHA-256 hashes leave your machine, never the content. No account, no server of your own, no lock-in: every proof can be checked later with standard tools (`shasum`, `openssl`, `ots`), even without twostamp.

```
$ twostamp stamp interview.mp4 transcript.txt
2 files -> SHA256SUMS.txt
RFC 3161: SHA256SUMS.txt.tsr (Oct 30 18:33:51 2026 GMT)
OpenTimestamps: SHA256SUMS.txt.ots (Bitcoin confirmation follows, then: twostamp upgrade)

$ twostamp verify
== SHA256SUMS.txt
  hashes:   OK (2 files)
  RFC 3161: OK, Oct 30 18:33:51 2026 GMT
  Bitcoin:  pending (run: twostamp upgrade)
```

## Why two timestamps

One timestamp is a single point of trust. A timestamp authority can disappear or be questioned; a Bitcoin anchor takes hours and needs explaining. Together they cover each other: RFC 3161 is immediate and accepted in legal and corporate settings, OpenTimestamps is decentralised and does not depend on anyone staying in business.

## Who it's for

- **Journalists and OSINT researchers.** The [Berkeley Protocol](https://www.ohchr.org/en/publications/policy-and-methodological-publications/berkeley-protocol-digital-open-source) asks for hashes and a documented chain of custody. `twostamp` adds independent proof of *when* you held the material, in one line, next to whatever capture tool you already use.
- **Developers** who want timestamp proofs inside their own software (audit logs, AI agent records, note systems) without writing the RFC 3161 and OpenTimestamps plumbing again.
- **Anyone who needs to show they had something first:** an idea, a text, a contract draft, research data, a deletion record.

It was built for a real case: securing a livestream recording as evidence, with source records, hashes and both timestamps.

Similar dual-anchor code exists inside other products ([yuppers-verify](https://github.com/Yuppers-LLC/yuppers-verify), [cosimo](https://github.com/steve-lomnes/cosimo)). `twostamp` is the standalone version for any file, with no service behind it.

## Install

```
curl -fsSLO https://raw.githubusercontent.com/MacStenk/twostamp/main/twostamp && chmod +x twostamp && mv twostamp /usr/local/bin/
pip install opentimestamps-client   # optional, for the Bitcoin proof
```

Needs `bash`, `openssl`, `curl` and `shasum` or `sha256sum`. Works on macOS and Linux.

## Usage

| Command | What it does |
|---|---|
| `twostamp stamp <file…>` | writes `SHA256SUMS.txt` (or `SHA256SUMS-<time>.txt` if one exists) plus `.tsr` and `.ots` in the current directory |
| `twostamp verify [dir]` | checks hashes, the RFC 3161 stamp and the Bitcoin proof of every `SHA256SUMS*.txt`; exit code 1 on any mismatch |
| `twostamp upgrade [dir]` | pulls the Bitcoin confirmation into the `.ots` files, run it a few hours after stamping |

Keep the `SHA256SUMS*.txt`, `.tsr`, `.ots` and `freetsa-*` files together with your data. That is the proof.

Another timestamp authority: set `TWOSTAMP_TSA_URL`, `TWOSTAMP_TSA_CA_URL` and `TWOSTAMP_TSA_CRT_URL`.

## Checking a proof without twostamp

```
shasum -a 256 -c SHA256SUMS.txt
openssl ts -verify -in SHA256SUMS.txt.tsr -data SHA256SUMS.txt -CAfile freetsa-cacert.pem -untrusted freetsa-tsa.crt
ots verify SHA256SUMS.txt.ots
```

## GitHub Action

Stamp your release files on every release:

```yaml
- uses: MacStenk/twostamp@v1
  with:
    files: dist/*
    working-directory: .
```

Then upload `SHA256SUMS.txt*` and `freetsa-*` as release assets. For signed build provenance of public repos, GitHub's own [artifact attestations](https://github.com/actions/attest) are the standard; `twostamp` adds a timestamp that is independent of GitHub.

## Legal weight

freetsa.org is free but not a *qualified* timestamp authority under the EU eIDAS regulation. If you need that, point `TWOSTAMP_TSA_URL` (and the two certificate URLs) at a qualified TSA. The Bitcoin proof is independent of any authority either way.

## What it proves, and what not

It proves that exactly these bytes existed no later than the stamped time. It does not prove who made them, that the content is true, or that no other copies exist. For authorship, sign the `SHA256SUMS.txt` with your own key (GPG, SSH or Nostr).

## Deutsch

`twostamp` belegt, dass Dateien zu einem Zeitpunkt unverändert existierten, mit zwei unabhängigen Zeitstempeln in einem Befehl: RFC 3161 (freetsa.org, sofort) und OpenTimestamps (Bitcoin, nach einigen Stunden bestätigt). Es gehen nur Prüfsummen raus, nie Inhalte.

```
twostamp stempeln <dateien…>   # stempeln
twostamp pruefen [ordner]      # prüfen
twostamp upgrade [ordner]      # Bitcoin-Bestätigung nachholen
```

Gedacht für Beweissicherung aus dem Netz, Urheberschafts-Nachweise für Ideen und Texte, Release-Dateien, Verträge und Löschprotokolle.

## License

MIT
