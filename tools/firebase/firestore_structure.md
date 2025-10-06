# Firebase Firestore Structure

```
/users/{uid}
  name: string
  email: string
  streakDays: number
  xp: number
  progress:
    {unitId}:
      {character}:
        completed: boolean
        score: number

/characters/{characterId}
  character: string
  pinyin: string
  meaning: string
  ttsUrl: string
  strokeData:
    width: number
    height: number
    paths: array<string>
  unit: string (unitId)

/units/{unitId}
  title: string
  description: string
  characters: array<string>
  color: string (hex)
```

# Firebase Storage Structure

```
/audio/
  cha.mp3
  shui.mp3
  fan.mp3
  tang.mp3
/strokes/
  tea.json
  water.json
```

> ⚠️ Upload the audio files first, copy their download URLs, and paste the links into the `ttsUrl` field in Firestore.
